//
//  NotesListModel.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 19.04.2022.
//

import Foundation
import CoreData


protocol NotesListModelable: AnyObject {
    func numberOfObjects(in section: Int) -> Int
    func cell(cellForRowAt indexPath: IndexPath) -> (String, String)
    func delete(at indexPaths: [IndexPath])
    func delete(_ note: Note)
    func object(at indexPath: IndexPath) -> Note?
    func deleteAllNotes()
    func createNote() -> Note
    func save()
}

final class NotesListModel: NSObject {
    private var fetchedResultsController: NSFetchedResultsController<Note>!
    private var view: NotesListViewable!
    
    init(view: NotesListViewable) {
        super.init()
        self.view = view
        configureFetchedResultsController()
    }
    
    private func configureFetchedResultsController(filter: String? = nil) {
        fetchedResultsController = CoreDataManager.shared.createNotesFetchedResultsController(filter: filter)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
}

extension NotesListModel: NotesListModelable {
    func createNote() -> Note {
        CoreDataManager.shared.createNote()
    }
    
    func object(at indexPath: IndexPath) -> Note? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func numberOfObjects(in section: Int) -> Int {
        fetchedResultsController.sections![section].numberOfObjects
    }
    
    func cell(cellForRowAt indexPath: IndexPath) -> (String, String) {
        (
            fetchedResultsController.object(at: indexPath).title,
            fetchedResultsController.object(at: indexPath).modificationDescription
        )
    }
    
    func delete(at indexPaths: [IndexPath]) {
        indexPaths
            .reversed()
            .forEach { CoreDataManager.shared.deleteNote(fetchedResultsController.object(at: $0)) }
    }
    
    func delete(_ note: Note) {
        CoreDataManager.shared.deleteNote(note)
    }
    
    func deleteAllNotes() {
        CoreDataManager.shared.deleteAllNotes()
    }
    
    func save() {
        CoreDataManager.shared.save()
    }
}

extension NotesListModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        view.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        view.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            view.insertRows(at: [newIndexPath!])
        case .delete:
            view.deleteRows(at: [indexPath!])
        case .update:
            view.reloadRows(at: [indexPath!])
        case .move:
            view.moveRow(at: indexPath!, to: newIndexPath!)
        default: view.reloadData()
        }
    }
}
