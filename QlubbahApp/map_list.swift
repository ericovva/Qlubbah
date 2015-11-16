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
import Haneke

class map_list: UIViewController,UITableViewDelegate, UITableViewDataSource,  MKMapViewDelegate, CLLocationManagerDelegate, UISearchResultsUpdating  {
    var resultSearchController = UISearchController()
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {   fetch_request()
        tableViewList.reloadData()
        _update()
        
        if (!resultSearchController.active ){
            fetch_request()
            tableViewList.reloadData()
        }
    }
    var ba: Int = 0
    var clubs: NSArray = []
    var core_data_result: NSArray = []
    var map_init = false
    var coords: CLLocationCoordinate2D?
    var allow = true
    var update_new = ""
    var selected_row = 0
    var allow_core_data_changes = false
    var changing = false
    var any_active_annotations = false
    
    
    @IBOutlet weak var iView: UIView!
    @IBOutlet weak var aIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var sort_button: UIBarButtonItem!
   
    @IBOutlet weak var seg_control: UISegmentedControl!
    @IBOutlet weak var tableViewList: UITableView!
    @IBAction func segControl(sender: AnyObject) {

        switch(sender.selectedSegmentIndex){
        case 0: //sender.subviews[0].tintColor = UIColor.whiteColor()
                sort_button.tintColor = UIColor.clearColor()
                sort_button.enabled = false
                if (!map_init){
                    init_map()
                    map_init = true
                }
                if any_active_annotations {
                    self.map_footer_panel.hidden = false
                }
                //self.locationManager.startUpdatingLocation()
                self.current_location_button.hidden = false
                tableViewList.hidden = true ;
                mapView.hidden = false
            
        default: init_map(); //sender.subviews[1].tintColor = UIColor.whiteColor()
            sort_button.tintColor = UIColor.yellowColor()
            sort_button.enabled = true
            tableViewList.reloadData() // мб причина вылетов
            if (map_init){
             //   _update()
                self.locationManager.stopUpdatingLocation();
            }
            
                self.current_location_button.hidden = true
                 self.map_footer_panel.hidden = true
                 tableViewList.hidden = false;
                 mapView.hidden = true
            
        }
    }
   
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var refreshControl:UIRefreshControl!
    
    override func viewWillAppear(animated: Bool) {
        if (self.search_activate){
            self.resultSearchController.searchBar.hidden = false

        }
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
    var search_activate = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //инициализация бокового меню
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            //self.view.addGestureRecognizer({  })
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
        
        
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.barTintColor = UIColor.whiteColor()
            controller.searchBar.tintColor = UIColor.orangeColor()
            controller.searchBar.setValue("Отмена", forKey: "_cancelButtonText")
            self.tableViewList.tableHeaderView = controller.searchBar
            search_activate = true
            
            return controller
        })()
          resultSearchController.hidesNavigationBarDuringPresentation = false
        
        
        // Reload the table
        self.tableViewList.reloadData()
        
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
        if resultSearchController.active {
            let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", resultSearchController.searchBar.text!)
            request.predicate = searchPredicate
            
        }
        if (SingletonObject.sharedInstance.sort != "name"){
            let sortDescriptor = NSSortDescriptor(key: SingletonObject.sharedInstance.sort, ascending: false)
            request.sortDescriptors = [sortDescriptor]
        }
        
        request.returnsObjectsAsFaults = false
        
        let result: NSArray = try! context.executeFetchRequest(request)
        core_data_result = result
        print("copeid core_data_result")
        allow_core_data_changes = true
        
       // for resulting in result {
         //   core_data_result.addObject(resulting)
        //}
        
  
    }
   
    
    
    
    
    func refresh(sender:AnyObject) {
        if (SingletonObject.sharedInstance.allow ) {
            refreshBegin({(x:Int) -> () in
//                if self.clubs_images.count != 0 {
//                    for (myKey,_) in self.clubs_images {
//                        //print(myKey)
//                        self.clubs_images.removeValueForKey(myKey)
//                    }
//                }
//                print("REFRESH:CLUBS_IMAGES_COUNT \(self.clubs_images.count)")
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
                        if (self.allow_core_data_changes){
                           self.compare_with_core_data()
                        }
                        else {
                            ("EXCEPTION: CORE DATA IS BUSY")
                        }
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
        self.changing = true
        var update: String = ""
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _update = userDefaults.stringForKey("update"){
            update = _update
        }
        if update != self.update_new {
            SingletonObject.sharedInstance.delete_data("Place")
            print("DELETED")
            self.add_data()
            print("ADD")
            SingletonObject.sharedInstance.delete_data("Photo") //здесь ошибка, я пытаюсь использовать core data с двух потоков в одном контексте походу
            print("Photo_was_deleted")
            userDefaults.setObject(self.update_new, forKey: "update")
            SingletonObject.sharedInstance.about_update_ids = ""
            //self._update()
            
        }
        else {
            self.change_data()
            //self._update()
        }
        print("fetch_begin")
        dispatch_async(dispatch_get_main_queue()) {
           self._update()
        }
    }
    func _update(){
        changing = false
        self.fetch_request()
        self.tableViewList.reloadData()
        SingletonObject.sharedInstance.allow = true
        mapView.removeAnnotations(mapView.annotations)
        self.init_map()
    }
    
    
    //Добавление данных в core data, полученных из запроса. Вызывается в случае обновления на сервере. (Через админку)
    func add_data(){
        if self.clubs_images.count != 0 {
            for (myKey,_) in self.clubs_images {
                //print(myKey)
                self.clubs_images.removeValueForKey(myKey)
            }
        }
        print("REFRESH:CLUBS_IMAGES_COUNT \(self.clubs_images.count)")
        var obj_saved = 0
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        for i in 0..<clubs.count {
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
                place.setValue((cN!).integerValue, forKey: "female")
            }
            if let cN :AnyObject? = (clubs[i])["male"]{
                place.setValue((cN!).integerValue, forKey: "male")
            }
            var age_female = 0
            var age_male = 0
            if let cN :AnyObject? = (clubs[i])["age_female"]{
                place.setValue(cN!, forKey: "age_female")
                age_female = (cN!).integerValue
            }
            if let cN :AnyObject? = (clubs[i])["age"]{
                place.setValue(cN!, forKey: "age")
                age_male = (cN!).integerValue
            }
            if let cN :AnyObject? = (clubs[i])["likes"]{
                place.setValue((cN!).integerValue, forKey: "likes")
            }
            if let cN :AnyObject? = (clubs[i])["people"]{
                place.setValue((cN!).integerValue, forKey: "people")
            }
            if let cN :AnyObject? = (clubs[i])["x"]{
                place.setValue(cN!, forKey: "x")
            }
            if let cN :AnyObject? = (clubs[i])["y"]{
                place.setValue(cN!, forKey: "y")
            }
            if let cN :AnyObject? = (clubs[i])["max_people"]{
                place.setValue(cN!, forKey: "max_people")
            }
            place.setValue( (age_female + age_male) / 2, forKey: "mid_age")
            
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
                }/*
                 let imgURL: NSURL = NSURL(string: str)!
                if let imgData: NSData = NSData(contentsOfURL: imgURL) {
                    place.setValue(imgData,forKey: "img")
                } */
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
                if (result[i].valueForKey("likes") != nil && (clubs[i]["likes"])!?.integerValue != nil ){
                    result[i].setValue((clubs[i]["likes"])!?.integerValue, forKey: "likes");
                    //result[i].setValue((clubs[i]["age"])!?.integerValue, forKey: "age");
                    //result[i].setValue((clubs[i]["age_female"])!?.integerValue, forKey: "age_female");
                    //result[i].setValue((clubs[i]["female"])!?.integerValue, forKey: "female");
                    //result[i].setValue((clubs[i]["male"])!?.integerValue, forKey: "male");
                    //result[i].setValue((clubs[i]["people"])!?.integerValue, forKey: "people");
                }
                if (result[i].valueForKey("male") != nil && (clubs[i]["male"])!?.integerValue != nil ){

                    result[i].setValue((clubs[i]["male"])!?.integerValue, forKey: "male");
                }
                if (result[i].valueForKey("female") != nil && (clubs[i]["female"])!?.integerValue != nil ){
                    result[i].setValue((clubs[i]["female"])!?.integerValue, forKey: "female");
                }
                if (result[i].valueForKey("age") != nil && (clubs[i]["age"]) != nil ){
                    if let age_ = clubs[i]["age"] {
                        result[i].setValue(age_, forKey: "age");
                    }
                    
                }
                if (result[i].valueForKey("age_female") != nil && (clubs[i]["age_female"]) != nil ){
                    if let age_ = clubs[i]["age_female"] {
                       result[i].setValue(age_, forKey: "age_female");
                    }
                }
                if (result[i].valueForKey("people") != nil && (clubs[i]["people"])!?.integerValue != nil ){
                    result[i].setValue((clubs[i]["people"])!?.integerValue, forKey: "people");
                }
        
                
              }
            } catch _ {print("error8: fetch error")}
        do {
            try context.save()
            print("change_data: Данные изменены успешно")
        } catch _ { print ("error4: Can't save object to core data")}
    }
    func error_mess(_title: String,_message: String){
        let alert = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.Alert)
        //alert.view.backgroundColor = UIColor.darkGrayColor()
        alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    

    
    
    @IBOutlet weak var map_footer_panel: UIView!
    @IBAction func like_button(sender: AnyObject) {
        let userDef = NSUserDefaults.standardUserDefaults()
        if (Reachability.isConnectedToNetwork()){
            if (userDef.boolForKey("auth")){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {//new
                        SingletonObject.sharedInstance.like_club(self.like_label,img: self.like_img,club_id: ((self.core_data_result[self.selected_row]).valueForKey("id") as? String)!)
                
                    dispatch_async(dispatch_get_main_queue()) {//new
                        //self.fetch_request()
                    }
                }

                
                
                
            }
            else {
                error_mess("Авторизуйтесь", _message: "Для этого действия необходима авторизация.")
            }
        }
        else {
            self.error_mess("Ошибка соединения", _message: "Прверьте подключение к Интернету.")
            
        }
    }
    @IBOutlet weak var like_img: UIImageView!
    @IBOutlet weak var like_label: UILabel!
    @IBAction func get_route(sender: AnyObject) {
        var addressToLinkTo = ""
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

    @IBAction func about_from_map(sender: AnyObject) {
        performSegueWithIdentifier("about", sender: nil)
        
    }
 
    func init_map(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        //locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 0)!
        var point_mas: [MKPointAnnotation] = []
        if (!changing){ //жесткий костыль
            for i in 0..<self.core_data_result.count{
                if let x = (core_data_result[i].valueForKey("x"))  {
                    if let y = (core_data_result[i].valueForKey("y")) {
                    
                    self.coords = CLLocationCoordinate2D(latitude: (x as! NSString).doubleValue, longitude: (y as! NSString).doubleValue)
                    
                    }
                }
                
                
                //self.coords = CLLocationCoordinate2D(latitude:
                //    (, longitude: (core_data_result[i].valueForKey("y") as! NSString).doubleValue)
                
                
                let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = self.coords!
                pointAnnotation.title = "\(i)"
                self.mapView?.addAnnotation(pointAnnotation)
                point_mas.append(pointAnnotation)
                //self.mapView?.centerCoordinate = self.coords!
            }
        }
        fitMapViewToAnnotaionList(point_mas)
    }
    
    
    @IBOutlet weak var current_location_button: UIButton!
    @IBAction func current_location_action(sender: AnyObject) {
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        //mapView.showsUserLocation = false //что она делает?? хз
    }
    func fitMapViewToAnnotaionList(annotations: [MKPointAnnotation]) -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<annotations.count {
            let annotation = annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
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
            if (!changing){
                
                if view.annotation!.isKindOfClass(MKUserLocation){
                    return
                }
                self.selected_row = view.tag
                let customView = (NSBundle.mainBundle().loadNibNamed("SubView", owner: self, options: nil))[0] as! CustomSubView;
                
                var calloutViewFrame = customView.frame;
                calloutViewFrame.origin = CGPointMake(-calloutViewFrame.size.width/2 + 15, -calloutViewFrame.size.height);
                customView.frame = calloutViewFrame;
                
                let cpa = view.annotation
                customView.name.text = core_data_result[view.tag].valueForKey("name") as? String
                customView.address.text = core_data_result[view.tag].valueForKey("place") as? String
                customView.m_c.text = String((core_data_result[view.tag]).valueForKey("male") as! Int)
                customView.w_a.text = (core_data_result[view.tag]).valueForKey("age_female") as? String
                customView.m_a.text = (core_data_result[view.tag]).valueForKey("age") as? String
                customView.w_c.text = String((core_data_result[view.tag]).valueForKey("female") as! Int)
                customView.c.text = String((core_data_result[view.tag]).valueForKey("people") as! Int)
                ////
                
                if let cN :AnyObject? = (core_data_result[view.tag]).valueForKey("img_src") as? String{
                    var str: String = "http://qlubbah.ru/"
                    let str2: String = cN! as! String
                    for c in str2.characters {
                        if (c != ",") {
                            str.append(c)
                        }
                        else {
                            break
                        }
                    }/*
                    let imgURL: NSURL = NSURL(string: str)!
                    if let imgData: NSData = NSData(contentsOfURL: imgURL) {
                    place.setValue(imgData,forKey: "img")
                    } */
                    if (str != "http://qlubbah.ru/"){
                        let cache = Shared.dataCache
                        cache.fetch(key: str).onSuccess { data in
                            customView.bg.image = UIImage(data: data)
                        }
                        cache.fetch(key: str).onFailure({ _ in
                            if let checkedUrl = NSURL(string: str) {
                                self.downloadImage(checkedUrl,key: str,img: customView.bg)
                            }
                        })
                        
                    }
                    else {
                        customView.bg.image = UIImage(named: "bg")
                    }
                }
                /////
                
                
//                if let imgData = core_data_result[view.tag].valueForKey("img"){
//
//                    customView.bg.image = UIImage(data: imgData as! NSData)
//                }
                like_label.text = String(((core_data_result[view.tag]).valueForKey("likes"))!)
                let userDef = NSUserDefaults.standardUserDefaults()
                let id = (core_data_result[view.tag]).valueForKey("id") as? String
                if userDef.boolForKey("auth"){
                    let was_liked = userDef.stringForKey("likes_list")
                    
                    if (was_liked!.rangeOfString("," + id! + ",") != nil){
                        like_img.image = UIImage(named: "active_like-iphone")
                    }
                    else {
                        like_img.image = UIImage(named: "like")
                    }
                }
                
                
                
                
                club_route_id = (core_data_result[view.tag].valueForKey("place") as? String)!
                
                view.addSubview(customView)
                view.bringSubviewToFront(customView)
                //zoom map to show callout
                let spanX = 1.0
                let spanY = 1.0
                
                let newRegion = MKCoordinateRegion(center:cpa!.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
                self.mapView?.setRegion(newRegion, animated: true)
                self.map_footer_panel.hidden = false
                self.any_active_annotations = true
                
            }
            else {
                error_mess("Ожидайте", _message: "Данные обновляются...")
            }
            
    }
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        
            self.map_footer_panel.hidden = true
            self.any_active_annotations = false
            view.subviews.forEach({ $0.removeFromSuperview() })
        if (!changing){
            fetch_request()
        }
        
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
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
        cell.clubName.text = (core_data_result[indexPath.row]).valueForKey("name") as? String
        if let _mcount = (core_data_result[indexPath.row]).valueForKey("people") as? Int {
                cell.mCount.text = String(_mcount)
        }
        if let _women = (core_data_result[indexPath.row]).valueForKey("female") as? Int {
            cell.women.text = String(_women) + " %"
        }
        if let _men = (core_data_result[indexPath.row]).valueForKey("male") as? Int {
               cell.men.text = String(_men) + " %"
        }
        
     
    
        
        let likes = (core_data_result[indexPath.row]).valueForKey("likes")
        if let likes_ = likes { cell.likes.text = "\(likes_)" }
        let userDef = NSUserDefaults.standardUserDefaults()
        let id = (core_data_result[indexPath.row]).valueForKey("id") as? String
        if userDef.boolForKey("auth"){
            if let was_liked = userDef.stringForKey("likes_list") {
                if let _id = id {
                    
                    if (was_liked.rangeOfString("," + _id + ",") != nil){
                        cell.like_hand_image_in_list.image = UIImage(named: "active_like-iphone")
                    }
                    else {
                        cell.like_hand_image_in_list.image = UIImage(named: "like")
                    }
                    
                }
          
                
            }
            else {
                print("userDef.stringForKey(likes_list) NILL")
            }
    
            
        }
        cell.club_id = id
        cell.club_number = indexPath.row
        cell.search = resultSearchController.searchBar.text!
        cell._view = self
        
        //cell.womenAge.text = (core_data_result[indexPath.row]).valueForKey("age_female") as? String
        //cell.menAge.text = (core_data_result[indexPath.row]).valueForKey("age") as? String
        if let womenAge = (core_data_result[indexPath.row]).valueForKey("age_female") as? String {
            if let menAge = (core_data_result[indexPath.row]).valueForKey("age") as? String {
                SingletonObject.sharedInstance.old_title(cell.womenAge, number: womenAge)
                SingletonObject.sharedInstance.old_title(cell.menAge, number: menAge)
            }
        }
        
        
        
        cell.clubPlace.text = (core_data_result[indexPath.row]).valueForKey("place") as? String
        /*if let imgData = core_data_result[indexPath.row].valueForKey("img"){
            cell.photo.image = UIImage(data: imgData as! NSData)
        }*/
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        
        
        
        if let cN :AnyObject? = (core_data_result[indexPath.row]).valueForKey("img_src") as? String{
            var str: String = "http://qlubbah.ru/"
            let str2: String = cN! as! String
            for c in str2.characters {
                if (c != ",") {
                    str.append(c)
                }
                else {
                    break
                }
            }/*
            let imgURL: NSURL = NSURL(string: str)!
            if let imgData: NSData = NSData(contentsOfURL: imgURL) {
            place.setValue(imgData,forKey: "img")
            } */
            if (str != "http://qlubbah.ru/"){
                
                if let img_from_array = clubs_images[str]{
                    cell.photo.image = img_from_array
                }
                else {
                    let cache = Shared.dataCache
                    cache.fetch(key: str).onSuccess { data in
                        cell.photo.image = UIImage(data: data)
                        self.clubs_images[str] = UIImage(data: data)
                    }
                    cache.fetch(key: str).onFailure({ _ in
                        cell.photo.image = UIImage(named: "bg")
                        if let checkedUrl = NSURL(string: str) {
                            self.downloadImage(checkedUrl,key: str)
                        }
                    })
                }
            }
            else {
                cell.photo.image = UIImage(named: "bg")
            }
            

        }

        
      
        
        
        
        return cell
    }
    
    var clubs_images = [String: UIImage]()
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    func downloadImage(url: NSURL, key: String,img: UIImageView = UIImageView()){
        //print("Started downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                //print("Finished downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
                let cache = Shared.dataCache
                
                cache.set(value: data, key: key)
                if self.seg_control.selectedSegmentIndex == 0 {
                    cache.fetch(key: key).onSuccess { data in
                        print(img)
                        img.image = UIImage(data: data)
                        
                    }
                    
                }
                else {
                    self.tableViewList.reloadData()
                }
            }
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected_row = indexPath.row
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor(
            red: CGFloat( 255 / 255.0),
            green: CGFloat(255 / 255.0),
            blue: CGFloat( 255 / 255.0),
            alpha: CGFloat(1.0)
        )
   
        performSegueWithIdentifier("about", sender: nil)
    }
    
    
   
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        allow_to_delete_map = false
        self.resultSearchController.searchBar.hidden = true
        resultSearchController.searchBar.resignFirstResponder()
        var error_message = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if (Reachability.isConnectedToNetwork()){
                var time_refresh = 0
                while (self.changing){
                    sleep(1)
                    time_refresh++
                    if (time_refresh > 40){
                        error_message = true
                        break;
                    }
                }
                if (!error_message){
                    if segue.identifier == "about" {
                        //передать данные в случае успеха
                        let svc = segue.destinationViewController as! About;
                        svc.id = ((self.core_data_result[self.selected_row]).valueForKey("id") as? String)!
                        if let img_ = ((self.core_data_result[self.selected_row]).valueForKey("img_src") as? String) {
                            svc.images_src = img_
                        
                            svc.mCount = String((self.core_data_result[self.selected_row]).valueForKey("people") as! Int)
                            svc.womenAge = ((self.core_data_result[self.selected_row]).valueForKey("age_female") as? String)!
                            svc.menAge = ((self.core_data_result[self.selected_row]).valueForKey("age") as? String)!
                            svc.women = String((self.core_data_result[self.selected_row]).valueForKey("female") as! Int)
                            svc.men  = String((self.core_data_result[self.selected_row]).valueForKey("male") as! Int)
                            svc.clubName = (self.core_data_result[self.selected_row]).valueForKey("name") as? String
                            svc.clubPlace = (self.core_data_result[self.selected_row]).valueForKey("place") as? String
                            svc.likes = String((self.core_data_result[self.selected_row]).valueForKey("likes") as! Int)
                        
                            svc.club_number = self.selected_row
                            if self.resultSearchController.active {
                                svc.search = self.resultSearchController.searchBar.text!
                            }
                        }
                        else {
                            print("ERROR!!")
                        }
                        svc.article = ((self.core_data_result[self.selected_row]).valueForKey("about") as? String)!
                        svc.name = ((self.core_data_result[self.selected_row]).valueForKey("name") as? String)!
                        svc.address = ((self.core_data_result[self.selected_row]).valueForKey("place") as? String)!
                        if (SingletonObject.sharedInstance.about_update_ids.rangeOfString("none") == nil && SingletonObject.sharedInstance.about_update_ids.rangeOfString("," + svc.id + ",") == nil) {
                            //обнвоить картинки
                            svc.update = true
                        }
                        else {
                            //не обновлять картинки
                            svc.update = false
                        }
                    }
                    
                }
                
                
            }
            else {
                error_message = true
            }
            dispatch_async(dispatch_get_main_queue()) {
                
                if (error_message){
                    self.error_mess("Ошибка соединения", _message: "Нет соединения с Интернетом")
                }
                //else {
                    //self.resultSearchController.active = false
                //}
            }
        }
        
        
        
        
        
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    var allow_to_delete_map = true
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (allow_to_delete_map ){
            
            self.mapView.showsUserLocation = false
            self.mapView.delegate = nil
            self.mapView.removeFromSuperview()
            self.mapView = nil
            
        }
      
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
  
   
    
    
}
