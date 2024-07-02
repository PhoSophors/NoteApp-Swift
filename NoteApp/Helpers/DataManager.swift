import Foundation
import CoreData

class DataManager {

    static let shared = DataManager()

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoteListDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Failed to save Core Data context: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Folder operations

    func saveFolder(name: String) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Folder", in: context) else {
            fatalError("Failed to find entity description for Folder")
        }
        let folder = Folder(entity: entity, insertInto: context)
        folder.folderName = name
        saveContext()
    }

    func fetchFolders() -> [Folder] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch folders: \(error)")
            return []
        }
    }

    func updateFolder(folder: Folder, newName: String) {
        folder.folderName = newName
        saveContext()
    }

    func deleteFolder(folder: Folder) {
        let context = persistentContainer.viewContext
        context.delete(folder)
        saveContext()
    }

    func fetchFolderByName(name: String) -> Folder? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "folderName ==[c] %@", name) // Case insensitive comparison
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch folder by name: \(error)")
            return nil
        }
    }

    // MARK: - Note operations

    func saveNote(title: String, description: String, folder: Folder) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else {
            fatalError("Failed to find entity description for Note")
        }
        let note = Note(entity: entity, insertInto: context)
        note.noteTitle = title
        note.noteDescription = description
        note.folder = folder
        saveContext()
    }

    func fetchNotes(for folder: Folder) -> [Note] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "folder == %@", folder)
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch notes: \(error)")
            return []
        }
    }

    func updateNote(note: Note, withTitle title: String, description: String) {
        note.noteTitle = title
        note.noteDescription = description
        saveContext()
    }

    func deleteNote(note: Note) {
        let context = persistentContainer.viewContext
        context.delete(note)
        saveContext()
    }
    

    func clearCoreData() {
        let context = persistentContainer.viewContext
        let fetchRequest1: NSFetchRequest<Folder> = Folder.fetchRequest()
        let fetchRequest2: NSFetchRequest<Note> = Note.fetchRequest()
        
        do {
            let folders = try context.fetch(fetchRequest1)
            for folder in folders {
                context.delete(folder)
            }
            
            let notes = try context.fetch(fetchRequest2)
            for note in notes {
                context.delete(note)
            }
            
            saveContext()
        } catch {
            print("Failed to clear Core Data: \(error)")
        }
    }

    

}
