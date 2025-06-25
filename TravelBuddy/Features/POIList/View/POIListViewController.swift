//
//  POIListViewController.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//

import UIKit
import Combine

public final class POIListViewController: UIViewController {
  // MARK: – Зависимость от абстракции
  private let viewModel: POIListViewModelProtocol

  // MARK: – UI + состояние
  private let tableView = UITableView()
  private var pois: [POI] = []
  private var cancellables = Set<AnyCancellable>()

  // MARK: – Инициализация
  public init(viewModel: POIListViewModelProtocol) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) не поддерживается") }

  // MARK: – Жизненный цикл
  public override func viewDidLoad() {
    super.viewDidLoad()
    title = "Places"
    view.backgroundColor = .systemBackground

    setupTableView()
    bindViewModel()
    viewModel.refresh()
  }

  // MARK: – Настройка UITableView
  private func setupTableView() {
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.dataSource = self
  }

  // MARK: – Привязка к ViewModel
  private func bindViewModel() {
    viewModel.poisPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newPois in
        self?.pois = newPois
        self?.tableView.reloadData()
      }
      .store(in: &cancellables)

    viewModel.errorPublisher
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] message in
        let alert = UIAlertController(
          title: "Error",
          message: message,
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self?.present(alert, animated: true)
      }
      .store(in: &cancellables)
  }
}

// MARK: – UITableViewDataSource
extension POIListViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    pois.count
  }

  public func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let poi = pois[indexPath.row]
    cell.textLabel?.text = poi.name
    return cell
  }
}
