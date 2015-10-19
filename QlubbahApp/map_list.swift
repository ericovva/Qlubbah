//
//  map_list.swift
//  SidebarMenu
//
//  Created by Эрик on 29.09.15.
//  Copyright © 2015 AppCoda. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation
import AddressBook

class map_list: UIViewController,UITableViewDelegate, UITableViewDataSource,  MKMapViewDelegate, CLLocationManagerDelegate  {
    var ba: Int = 0
    var clubs: NSArray = []
    var core_data_result: NSArray = []
    var map_init = false
    var coords: CLLocationCoordinate2D?
    var allow = true
    var update_new = ""
    var selected_row = 0
 
    
    @IBOutlet weak var iView: UIView!
    @IBOutlet weak var aIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!

   
    @IBOutlet weak var seg_control: UISegmentedControl!
    @IBOutlet weak var tableViewList: UITableView!
    @IBAction func segControl(sender: AnyObject) {

        switch(sender.selectedSegmentIndex){
        case 0:
            
                if (!map_init){
                    init_map()
                    map_init = true
                }
                tableViewList.hidden = true ;
                mapView.hidden = false
            
        default:
            
                 tableViewList.hidden = false;
                 mapView.hidden = true
            
        }
    }
   
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var refreshControl:UIRefreshControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //при возвращении вызывается эта функция вызывается
        self.fetch_request()
        self.tableViewList.reloadData()
        if (core_data_result.count > 0) {
            print("viewWillAppear: Данные из core data получены успешно")
            //вызов функции переключателя в зависимости от глобальной переменной
            segControl(seg_control)
        }
        else {
            print("viewWillAppear: Core data пуста")
            //ждать обновления
            //segControl(seg_control)
            //if (Reachability.isConnectedToNetwork()){
                
            //}
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //инициализация бокового меню
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            print("error1: revealViewController == nil")
        }
        //инициализация pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableViewList.addSubview(refreshControl)
        //стиль плиток
        iView.layer.borderWidth = 0
        iView.layer.cornerRadius = 7
        //убрать полосы между лишними строками таблицы
        tableViewList.tableFooterView = UIView()
        //инициализация переключателя
        seg_control.selectedSegmentIndex = SingletonObject.sharedInstance.view;
        seg_control.layer.borderWidth = 1;
        seg_control.layer.borderColor = UIColor.yellowColor().CGColor
        seg_control.layer.cornerRadius = 5
        //посылка запроса на обновление данных (асинхронно), в это время инициализируем все из отправленного запроса в core data
        stop_indicator()
        if (Reachability.isConnectedToNetwork()){
            start_indicator()
            refreshBegin({(x:Int) -> () in
                    self.tableViewList.reloadData()
                    self.refreshControl.endRefreshing()
            })
        }
        else {
            print("viewDidLoad: no connection to the internet")
        }
     
        
    }
    
    
    
    
    
    
    func start_indicator(){
        iView.hidden = false
        aIndicator.hidden = false
        aIndicator.startAnimating()
    }
    func stop_indicator(){
        iView.hidden  = true
        aIndicator.hidden = true
        aIndicator.stopAnimating()
    }
    
    
    
    
    
    func fetch_request() {
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Place")
        
        if (SingletonObject.sharedInstance.sort != "name"){
            let sortDescriptor = NSSortDescriptor(key: SingletonObject.sharedInstance.sort, ascending: false)
            request.sortDescriptors = [sortDescriptor]
        }
        
        request.returnsObjectsAsFaults = false
        
        core_data_result = try! context.executeFetchRequest(request)
  
    }
   
    
    
    
    
    func refresh(sender:AnyObject) {
        if (SingletonObject.sharedInstance.allow ) {
            refreshBegin({(x:Int) -> () in
                self.tableViewList.reloadData()
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    func refreshBegin(refreshEnd:(Int) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
          if (Reachability.isConnectedToNetwork()){
                print("refreshing");
                //if (SingletonObject.sharedInstance.allow ) {
                    self.get_inf2()
                //}
                SingletonObject.sharedInstance.allow  = false
                while (!SingletonObject.sharedInstance.allow ){
                    sleep(1)
                    //здесь можно поставить connection time out
                }
           }
           else {
                print("refresh: no connection to the internet");
           }
           dispatch_async(dispatch_get_main_queue()) {
                self.stop_indicator();
                refreshEnd(0)
           }
        }
    }
    
    
    func httpRequest(input: NSURL,completion: (result: NSArray) -> Void){
        let task = NSURLSession.sharedSession().dataTaskWithURL(input) {(data, response, error) in
            if let _data = data {
                if let data_error: NSData = _data {
                    if let result = NSString(data: data_error, encoding: NSUTF8StringEncoding){
                        if let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                            do{
                            let jsonArray = try (NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSArray
                                print("httpRequest: завершено")
                            completion(result: jsonArray)
                            }
                            catch _ {
                                print("error5: jsonArrayError")
                            }
                        }
                        else {
                            print("error3: error in encoding jsonData")
                        }
                    }
                }
            }
            else {
                print("error2: no data from request");
            }
            
        }
        
        task.resume()
        
    }
    
    func get_inf(){
        if let url = NSURL(string: "http://qlubbah.ru/api.php?keys=1&action=club_data") {
            httpRequest(url) {
                (result: NSArray) in
                //dispatch_async(dispatch_get_main_queue()) {
                    if let _result:NSArray = result{
                            self.clubs = _result
                            print("get_inf: результат получен - массив длины \(self.clubs.count)")
                            self.compare_with_core_data()
                    }
                    else {
                        print("warning1: result is nil")
                    }
                //}
            }
        }
        else {
            print("error0: invalid url")
        }

    }
    
    //получение данных об обновлениях на сервере
    func get_inf2(){
        if let url = NSURL(string: "http://qlubbah.ru/api.php?action=club_cng_time&keys=1") {
            httpRequest2(url) {
                (result: NSDictionary) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let _result:NSDictionary = result{
                        self.update_new = _result["time"] as! String
                        print("get_inf2: получен ответ с сервера \(self.update_new) обновление сервера")
                        self.get_inf()
                    }
                    else {
                        print("warning1: result is nil")
                    }
                }
            }
        }
        else {
            print("error0: invalid url")
        }
    }
    func httpRequest2(input: NSURL,completion: (result: NSDictionary) -> Void){
        let task = NSURLSession.sharedSession().dataTaskWithURL(input) {(data, response, error) in
            if let _data = data {
                if let data_error: NSData = _data {
                    if let result = NSString(data: data_error, encoding: NSUTF8StringEncoding){
                        if let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                            do {
                                let jsonDict = (try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSDictionary
                                print("httpRequest2: завершено")
                                completion(result: jsonDict)
                            } catch {
                                print("httpRequest2: error in data encoding!")
                            }
                                               }
                        else {
                            print("error3: error in encoding jsonData")
                        }
                    }
                }
            }
            else {
                print("error2: no data from request");
            }
            
        }
        
        task.resume()
        
    }
    //Выбор действия в зависимости от информации из запроса get_iinf2 (либо полное обновление core data, либо обновление метаинформации)
    func compare_with_core_data(){
        
        var update: String = ""
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _update = userDefaults.stringForKey("update"){
            update = _update
        }
        if update != self.update_new {
            SingletonObject.sharedInstance.delete_data("Place")
            self.add_data()
            SingletonObject.sharedInstance.delete_data("Photo")
            userDefaults.setObject(self.update_new, forKey: "update")
            SingletonObject.sharedInstance.about_update_ids = ""
            
        }
        else {
            self.change_data()
        }
        print("fetch_begin")
        dispatch_async(dispatch_get_main_queue()) {
            self.fetch_request()
            self.tableViewList.reloadData()
            SingletonObject.sharedInstance.allow = true
        }
    }
    
    
    //Добавление данных в core data, полученных из запроса. Вызывается в случае обновления на сервере. (Через админку)
    func add_data(){
        var obj_saved = 0
        for i in 0..<clubs.count {
            let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            let context:NSManagedObjectContext = appDel.managedObjectContext
            let place = NSEntityDescription.insertNewObjectForEntityForName("Place", inManagedObjectContext: context)
            
            if let cN :AnyObject? = (clubs[i])["id"]{
                place.setValue(cN! , forKey: "id")
            }
            if let cN :AnyObject? = (clubs[i])["club_name"]{
                place.setValue(cN! as! String, forKey: "name");
            }
            if let cN :AnyObject? = (clubs[i])["club_place"]{
                place.setValue(cN!, forKey: "place")
            }
            if let cN :AnyObject? = (clubs[i])["about"]{
                place.setValue(cN! , forKey: "about")
            }
            if let cN :AnyObject? = (clubs[i])["female"]{
                place.setValue(cN!, forKey: "female")
            }
            if let cN :AnyObject? = (clubs[i])["male"]{
                place.setValue(cN!, forKey: "male")
            }
            if let cN :AnyObject? = (clubs[i])["age_female"]{
                place.setValue(cN!, forKey: "age_female")
            }
            if let cN :AnyObject? = (clubs[i])["age"]{
                place.setValue(cN!, forKey: "age")
            }
            if let cN :AnyObject? = (clubs[i])["likes"]{
                place.setValue((cN!).integerValue, forKey: "likes")
            }
            if let cN :AnyObject? = (clubs[i])["people"]{
                place.setValue(cN!, forKey: "people")
            }
            if let cN :AnyObject? = (clubs[i])["x"]{
                place.setValue(cN!, forKey: "x")
            }
            if let cN :AnyObject? = (clubs[i])["y"]{
                place.setValue(cN!, forKey: "y")
            }
            
            if let cN :AnyObject? = (clubs[i])["photo"]{
                var str: String = "http://qlubbah.ru/"
                let str2: String = cN! as! String
                place.setValue(str2, forKey: "img_src")
                for c in str2.characters {
                    if (c != ",") {
                        str.append(c)
                    }
                    else {
                        break
                    }
                }
                 let imgURL: NSURL = NSURL(string: str)!
                if let imgData: NSData = NSData(contentsOfURL: imgURL) {
                    place.setValue(imgData,forKey: "img")
                }
            }
            do {
                try context.save()
            } catch _ { print ("error4: Can't save object to core data")}
            obj_saved++
        }
        print("add_data: Данные сохранены успешно. Всего: \(obj_saved)")
    }
   
    // Изменении легких метаданных. Вызывается в случае если обновлений на сервере не происходило.(Через админку)
    func change_data(){
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: "Place")
        request.returnsObjectsAsFaults = false
         do {
            let result:NSArray = try context.executeFetchRequest(request)
            for i in 0..<result.count {
                result[i].setValue((clubs[i]["likes"])!?.integerValue, forKey: "likes");
            }
        }    catch {
                print("error8: could not load any Objective-C class information from the dyld shared cache. This will significantly reduce the quality of type information available.")
        }
        
        do {
            try context.save()
            print("change_data: Данные изменены успешно")
        } catch _ { print ("error4: Can't save object to core data")}
        
        
    }
    

    
    
    @IBOutlet weak var map_footer_panel: UIView!
    @IBAction func like_button(sender: AnyObject) {
    }
    @IBOutlet weak var like_img: UIImageView!
    @IBOutlet weak var like_label: UILabel!
    @IBAction func get_route(sender: AnyObject) {
        var addressToLinkTo = ""
        
        //Fill the container with an address
        
        addressToLinkTo = "http://maps.apple.com/?daddr=\(club_route_id)&saddr=Current+Location"
        
        if let st = addressToLinkTo.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()){
            let url = NSURL(string: st)
            UIApplication.sharedApplication().openURL(url!)
        }
        
        
    }
    
    
    var club_route_id: String = ""
    var locationManager: CLLocationManager!
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        print("present location : \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
    }

 
    func init_map(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        //locationManager.startUpdatingLocation()
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        //mapview setup to show user location
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        
    
        for i in 0..<self.core_data_result.count{
            
            self.coords = CLLocationCoordinate2D(latitude:
                (core_data_result[i].valueForKey("x") as! NSString).doubleValue, longitude: (core_data_result[i].valueForKey("y") as! NSString).doubleValue)
            
            
            let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = self.coords!
            pointAnnotation.title = "\(i)"
            self.mapView?.addAnnotation(pointAnnotation)
            self.mapView?.centerCoordinate = self.coords!
            
        }
        
        
        
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        return renderer
    }
    
    func mapView (mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            
          
            if annotation.isKindOfClass(MKUserLocation){
                return nil
            }
            else {
                let pinView:MKPinAnnotationView = MKPinAnnotationView()
                pinView.annotation = annotation
 
 
            pinView.pinColor = MKPinAnnotationColor.Green
            pinView.animatesDrop = true
            pinView.canShowCallout = false
            pinView.tag = (annotation.title!! as NSString).integerValue
                return pinView
            }
            
    }
    
    func mapView(mapView: MKMapView,
        didSelectAnnotationView view: MKAnnotationView){
            if view.annotation!.isKindOfClass(MKUserLocation){
                return
            }
            let customView = (NSBundle.mainBundle().loadNibNamed("SubView", owner: self, options: nil))[0] as! CustomSubView;
            
            var calloutViewFrame = customView.frame;
            calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 15, -calloutViewFrame.size.height);
            customView.frame = calloutViewFrame;
            
            let cpa = view.annotation
            customView.name.text = core_data_result[view.tag].valueForKey("name") as? String
            customView.address.text = core_data_result[view.tag].valueForKey("place") as? String
            club_route_id = (core_data_result[view.tag].valueForKey("place") as? String)!
            
            view.addSubview(customView)
            view.bringSubviewToFront(customView)
            //zoom map to show callout
            let spanX = 0.01
            let spanY = 0.01
            
            let newRegion = MKCoordinateRegion(center:cpa!.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            self.mapView?.setRegion(newRegion, animated: true)
            self.map_footer_panel.hidden = false
    }
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        self.map_footer_panel.hidden = true 
        view.subviews.forEach({ $0.removeFromSuperview() })
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
         print("LL")
    }
    
    
    
    

  
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return core_data_result.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ClubTableViewCell
        cell.photo.layer.cornerRadius = 10
        cell.photo.clipsToBounds = true
        //print((core_data_result[indexPath.row]).valueForKey("name"))
        cell.clubName.text = (core_data_result[indexPath.row]).valueForKey("name") as? String
        cell.mCount.text = (core_data_result[indexPath.row]).valueForKey("people") as? String
        let likes = (core_data_result[indexPath.row]).valueForKey("likes")
        if let likes_ = likes { cell.likes.text = "\(likes_)" }
        cell.womenAge.text = (core_data_result[indexPath.row]).valueForKey("age_female") as? String
        cell.menAge.text = (core_data_result[indexPath.row]).valueForKey("age") as? String
        cell.women.text = (core_data_result[indexPath.row]).valueForKey("female") as? String
        cell.men.text = (core_data_result[indexPath.row]).valueForKey("male") as? String
        cell.clubPlace.text = (core_data_result[indexPath.row]).valueForKey("place") as? String
        
        if let imgData = core_data_result[indexPath.row].valueForKey("img"){
            cell.photo.image = UIImage(data: imgData as! NSData)
        }
        //print(  (core_data_result[indexPath.row]).valueForKey("id") )
        
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected_row = indexPath.row
        performSegueWithIdentifier("about", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "about" {
            let svc = segue.destinationViewController as! About;
            svc.id = ((core_data_result[selected_row]).valueForKey("id") as? String)!
            if let img_ = ((core_data_result[selected_row]).valueForKey("img_src") as? String) {
                svc.images_src = img_
            }
            else {
                print("ERROR!!")
            }
            svc.article = ((core_data_result[selected_row]).valueForKey("about") as? String)!
            svc.name = ((core_data_result[selected_row]).valueForKey("name") as? String)!
            if (SingletonObject.sharedInstance.about_update_ids != "none" && SingletonObject.sharedInstance.about_update_ids.rangeOfString("," + svc.id + ",") == nil) {
                //обнвоить картинки
                svc.update = true               
            }
            else {
                //не обновлять картинки
                svc.update = false
            }
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
  
   
    
    
}
