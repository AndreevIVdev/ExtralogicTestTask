//
//  CoreDataManager.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 18.04.2022.
//

import Foundation
import CoreData

// MARK: - Class CoreDataManager
final class CoreDataManager {
    
    // MARK: - Public Properties
    static let shared = CoreDataManager(modelName: "ExtralogicTestTask")
    
    // MARK: - Private Properties
    private let persistentContainer: NSPersistentContainer
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Initializers
    private init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // MARK: - Public Methods
    func save() {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            print("An error ocurred while saving: \(error.localizedDescription)")
        }
    }
    
    func load() {
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

// MARK: - Notes storage and handling
extension CoreDataManager {
    func createNote() -> Note {
        let note = Note(context: viewContext)
        note.title = ""
        note.text = ""
        note.changed = Date()
        note.created = Date()
        save()
        return note
    }
    
    func fetchNotes(filter: String? = nil) -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.changed, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let filter = filter {
            let predicate = NSPredicate(format: "text contains[cd] %@", filter)
            request.predicate = predicate
        }
        
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func deleteNote(_ note: Note) {
        viewContext.delete(note)
        save()
    }
    
    func deleteAllNotes() {
        let notes = fetchNotes()
        for note in notes {
            deleteNote(note)
        }
    }
    
    func createNotesFetchedResultsController(filter: String? = nil) -> NSFetchedResultsController<Note> {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.changed, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let filter = filter {
            let predicate = NSPredicate(format: "text contains[cd] %@", filter)
            request.predicate = predicate
        }
        
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
