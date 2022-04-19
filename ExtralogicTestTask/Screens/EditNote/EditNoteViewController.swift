//
//  EditNoteViewController.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 18.04.2022.
//

import UIKit

// MARK: - EditNoteViewControllerDelegate
protocol EditNoteViewControllerDelegate: AnyObject {
    func updateNote()
    func delete(_ note: Note)
}

// MARK: - EditNoteViewController
final class EditNoteViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: EditNoteViewControllerDelegate?
    
    // MARK: - Private Properties
    private let createdLabel: UILabel = .init()
    private let changedLabel: UILabel = .init()
    private let titleTextField: UITextField = .init()
    private var textView: UITextView = .init()
    
    private var note: Note!
    
    // MARK: - Initializers
    init(note: Note) {
        super.init(nibName: nil, bundle: nil)
        self.note = note
        print("\(String(describing: type(of: self))) INIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinitializers
    deinit {
        print("\(String(describing: type(of: self))) DEINIT")
    }
    
    // MARK: - Overrride functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureCreatedLabel()
        configureChangedLabel()
        configureTitleTextField()
        configureTextView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent else { return }
        guard note.title != titleTextField.text.orEmpty || note.text != textView.text.orEmpty else { return }
        note.changed = Date()
        note.title = titleTextField.text.orEmpty
        note.text = textView.text.orEmpty
        if note.title.isEmpty {
            delegate?.delete(note)
        } else {
            delegate?.updateNote()
        }
    }
    
    // MARK: - Private methods
    private func configureViewController() {
        view.addSubViews(createdLabel, changedLabel, titleTextField, textView)
        view.backgroundColor = .systemBackground
        title = "Edit note"
    }
    
    private func configureCreatedLabel() {
        createdLabel.text = "Created at: " + note.created.inShortFormat()
        createdLabel.font = .preferredFont(forTextStyle: .caption2)
        createdLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            createdLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func configureChangedLabel() {
        changedLabel.text = "Changed at: " + note.changed.inShortFormat()
        changedLabel.font = .preferredFont(forTextStyle: .caption2)
        changedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            changedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func configureTitleTextField() {
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            titleTextField.topAnchor.constraint(equalTo: createdLabel.bottomAnchor, constant: 5),
            titleTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        titleTextField.borderStyle = .roundedRect
        titleTextField.backgroundColor = .white
        titleTextField.delegate = self
        titleTextField.text = note.title
        titleTextField.placeholder = "Title"
    }
    
    private func configureTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            textView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor),
            textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
        textView.delegate = self
        if note.text.isEmpty {
            textView.text = "Text"
            textView.textColor = UIColor.lightGray
        } else {
            textView.text = note.text
        }
    }
}

// MARK: - UITextFieldDelegate
extension EditNoteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate
extension EditNoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Text"
            textView.textColor = UIColor.lightGray
        }
    }
}
