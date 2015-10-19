//
//  SingletonObject.swift
//  QlubbahApp
//
//  Created by Эрик on 06.10.15.
//  Copyright © 2015 qlubbah. All rights reserved.
//
import CoreData
final class SingletonObject {
    
    static let sharedInstance = SingletonObject()
    
    private init() {
    }
    internal var view = 0
    internal var sort = "name"
    internal var allow = true
    internal var about_update_ids = "none"
    internal var update_about = false
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
}