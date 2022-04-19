//
//  NotesListViewController.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 18.04.2022.
//

import UIKit

// MARK: - NotesListViewable
protocol NotesListViewable: AnyObject {
    func beginUpdates()
    func endUpdates()
    func insertRows(at indexPaths: [IndexPath])
    func deleteRows(at indexPaths: [IndexPath])
    func reloadRows(at indexPaths: [IndexPath])
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath)
    func reloadData()
}

// MARK: - NotesListViewController
final class NotesListViewController: UIViewController {
    
    // MARK: - Private Properties
    fileprivate var model: NotesListModelable!
    private let tableView: UITableView = .init()
    private var addButton: UIButton = .init()
    private var editButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    private var spacerButton: UIBarButtonItem!
    private var deleteAllButton: UIBarButtonItem!
    private var deleteButton: UIBarButtonItem!
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
        configureNavigationButtons()
        configureAddButton()
    }
    
    // MARK: - Private Methods
    private func configureViewController() {
        model = NotesListModel(view: self)
        view.addSubViews(tableView, addButton)
        view.backgroundColor = .systemBackground
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotesListTableViewCell.self, forCellReuseIdentifier: NotesListTableViewCell.description())
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    private func configureNavigationButtons() {
        editButton = .init(image: Images.edit, style: .plain, target: self, action: #selector(enterEditingMode))
        cancelButton = .init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditing))
        spacerButton = .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        deleteAllButton = .init(title: "Delete All", style: .plain, target: self, action: #selector(deleteAllNotes))
        deleteButton = .init(image: Images.trash, style: .plain, target: self, action: #selector(deleteSelectedNotes))
        navigationItem.rightBarButtonItems = [editButton]
    }
    
    private func configureAddButton() {
        addButton.backgroundColor = .systemOrange
        addButton.titleLabel?.font = .systemFont(ofSize: 30)
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 25
        addButton.setTitleColor(.systemOrange, for: .highlighted)
        addButton.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        addButton.frame.origin = CGPoint(x: view.frame.width - 80, y: view.frame.height - 80)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalTo: addButton.heightAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
}

// MARK: - Extension UITableViewDataSource
extension NotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.numberOfObjects(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotesListTableViewCell.description(), for: indexPath)
        var contentConfiguration = cell.defaultContentConfiguration()
        (contentConfiguration.text, contentConfiguration.secondaryText) = model.cell(cellForRowAt: indexPath)
        cell.contentConfiguration = contentConfiguration
        return cell
    }
}

// MARK: - Extension UITableViewDelegate
extension NotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            toolbarItems = [spacerButton, deleteButton]
        } else {
            pushEditNoteViewController()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathForSelectedRow == nil || tableView.indexPathForSelectedRow!.isEmpty {
            toolbarItems = [spacerButton, deleteAllButton]
        }
    }
}

// MARK: - Extension target functions
extension NotesListViewController {
    
    @objc private func enterEditingMode() {
        navigationItem.rightBarButtonItems = [cancelButton]
        navigationController?.isToolbarHidden = false
        toolbarItems = [spacerButton, deleteAllButton]
        addButton.isHidden = true
        tableView.setEditing(true, animated: true)
    }
    
    @objc private func addNote() {
        pushEditNoteViewController()
    }
    
    @objc private func cancelEditing() {
        cancelEditingMode()
    }
    
    private func cancelEditingMode() {
        navigationItem.rightBarButtonItems = [editButton]
        navigationController?.isToolbarHidden = true
        addButton.isHidden = false
        tableView.setEditing(false, animated: true)
    }
    
    @objc private func deleteSelectedNotes() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete Selected", style: .destructive) { [weak self] _ in
            self?.deleteSelected()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
    
    @objc private func deleteAllNotes() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete All", style: .destructive) { [weak self] _ in
            self?.deleteAll()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
}

// MARK: - Extension Navigation functions
extension NotesListViewController {
    @objc private func pushEditNoteViewController() {
        var note: Note!
        if let indexPath = tableView.indexPathForSelectedRow {
            note = model.object(at: indexPath)
        } else {
            note = model.createNote()
        }
        
        let editNoteViewController = EditNoteViewController(note: note)
        editNoteViewController.delegate = self
        
        navigationController?.pushViewController(editNoteViewController, animated: true)
    }
}

// MARK: - Extension delete functions
extension NotesListViewController {

    private func deleteAll() {
        model.deleteAllNotes()
        cancelEditingMode()
    }
    
    private func deleteSelected() {
        if let rows = tableView.indexPathsForSelectedRows {
            let sortedArray = rows.sorted { $0.row < $1.row }
            model.delete(at: sortedArray)
        }
        cancelEditingMode()
    }
}

// MARK: - Extension NotesListViewable
extension NotesListViewController: NotesListViewable {
    
    func beginUpdates() {
        tableView.beginUpdates()
    }
    
    func endUpdates() {
        tableView.endUpdates()
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func deleteRows(at indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        tableView.moveRow(at: indexPath, to: newIndexPath)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - Extension EditNoteViewControllerDelegate
extension NotesListViewController: EditNoteViewControllerDelegate {
    
    func updateNote() {
        model.save()
    }
    
    func delete(_ note: Note) {
        model.delete(note)
    }
}
