//
//  SingletonObject.swift
//  QlubbahApp
//
//  Created by Эрик on 06.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//
import CoreData
import MapKit
final class SingletonObject {
    
    static let sharedInstance = SingletonObject()
    
    private init() {
    }
    internal var view = 0
    internal var sort = "name"
    internal var allow = true
    internal var about_update_ids = "none"
    internal var update_about = false
    internal var map = MKMapView!()
    internal var map_init = false
    internal func delete_data(entity_name:String) {
        
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext
        let request = NSFetchRequest(entityName: entity_name)
        request.returnsObjectsAsFaults = false
        let result:NSArray = try! context.executeFetchRequest(request)
        if(result.count>0)
        {
            for res in result{
                print("Will be deleted")
                context.deleteObject(res as! NSManagedObject)
            }
            do {
                try context.save()
            } catch _ { print ("error7: Can't delete object from core data")}
        }
        else {
            print("Нет объектов для удаления")
        }
        
        
    }
    
    ///
    func like_club(label: UILabel, img: UIImageView,club_id: String){
        print("CLICK")
        let userDef = NSUserDefaults.standardUserDefaults()
        let _id_ = userDef.stringForKey("id")
        let _hash_ = userDef.stringForKey("hash")
        //let _club_id_ = (core_data_result[club_number]).valueForKey("id") as? String
        if let url = NSURL(string: "http://qlubbah.ru/api.php?keys=1&action=like&id=\(_id_!)&hash=\(_hash_!)&club_id=\(club_id)") {
            self.httpRequest(url) {
                (result: NSDictionary) in
                //dispatch_async(dispatch_get_main_queue()) {
                if let _result:NSDictionary = result{
                    //if (self.allow_core_data_changes){
                        print(_result)
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            let str = userDef.stringForKey("likes_list")
                            var new_count2: String!
                            var delete = false
                            var new_count: String!
                            if ( str?.rangeOfString(",\(club_id),") == nil ){
                                new_count = label.text!
                                label.text = "\(Int(new_count)! + 1)"
                                img.image = UIImage(named: "active_like-iphone")
                                new_count2 = "\(Int(new_count)! + 1)"
                            }
                            else {
                                new_count = label.text!
                                label.text = "\(Int(new_count)! - 1)"
                                img.image = UIImage(named: "like")
                                delete = true
                                new_count2 = "\(Int(new_count)! - 1)"
                            }
                            if (delete){
                                let newString = str!.stringByReplacingOccurrencesOfString(",\(club_id),", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                userDef.setObject(newString, forKey: "likes_list")
                                print(newString)
                            }
                            else {
                                let newString = str! + ",\(club_id),"
                                userDef.setObject(newString, forKey: "likes_list")
                                print(newString)
                                
                            }
                            //новая фишка надо протестить! dispatch block
                            dispatch_async(dispatch_get_main_queue()) {
                            
                                let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
                                
                                let context:NSManagedObjectContext = appDel.managedObjectContext
                                let request = NSFetchRequest(entityName: "Place")
                                
                                let searchPredicate = NSPredicate(format: "SELF.id = %@", club_id)
                                request.predicate = searchPredicate
                                
                                request.returnsObjectsAsFaults = false
                                do{
                                    let result:NSArray = try context.executeFetchRequest(request)
                                    result[0].setValue(Int(new_count2), forKey: "likes");
                                    print("CHANGE: \(result[0])")
                                } catch _ {
                                    print("ERROR!!")
                                }
                                
                             
                                
                                do {
                                    print("start")
                                    try context.save()
                                    print("like_club: Данные изменены успешно")
                                } catch _ { print ("error4: Can't save object to core data")}
                                
                            
                            }
                            
                            
                            
                            
                        }
                    //}
                    //else {
                    //    ("EXCEPTION: CORE DATA IS BUSY")
                    //}
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
    
    func httpRequest(input: NSURL,completion: (result: NSDictionary) -> Void){
        let task = NSURLSession.sharedSession().dataTaskWithURL(input) {(data, response, error) in
            if let _data = data {
                if let data_error: NSData = _data {
                    if let result = NSString(data: data_error, encoding: NSUTF8StringEncoding){
                        if let jsonData = result.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                            do {
                                let jsonDict = (try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])) as! NSDictionary
                                print("httpRequest: завершено")
                                completion(result: jsonDict)
                            } catch {
                                print("httpRequest: error in data encoding!")
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
    
    
    ////
    func old_title(label: UILabel, number: String) {
        var st = "  лет"
        var num = Int(number)
        if (num != nil){
            if (num! > 20 || num! < 5){
                num = num! % 10;
                switch(num!){
                case 1: st = "  год"
                case 2,3,4: st = "  года"
                default: st = "  лет"
                }
                
            }
            
        }
       
        
        
        label.text = number + st
    }
    
    
    
    
    
}