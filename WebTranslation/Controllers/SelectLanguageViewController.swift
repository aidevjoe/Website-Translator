import UIKit

class SelectLanguageViewController: BaseViewController {

    private let languages: [String]
    
    public var didSelectedCompleted: ((String) -> Void)?
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorColor = Theme.Color.globalColor
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [view.heightAnchor.constraint(equalTo: self.view.heightAnchor),
             view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
             view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
             view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)]
        )
        view.backgroundColor = .clear
        return view
    }()
    
    init(languages: [String]) {
        self.languages = languages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(languages)
        tableView.reloadData()
    }
    
}

extension SelectLanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
            cell?.backgroundColor = .clear
            cell?.textLabel?.textColor = .white
            let view = UIView(frame: cell!.bounds)
            view.backgroundColor = Theme.Color.globalColor
            cell?.selectedBackgroundView = view
        }
        let language = languages[indexPath.row]
        cell?.textLabel?.text = language
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectedCompleted?(languages[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
