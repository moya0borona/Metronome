//
//  PickerViewController.swift
//  MetronomeAVA_PlaySetup
//
//  Created by Андрей Андриянов on 22.11.2024.
//

import UIKit

protocol PickerDelegate: AnyObject {
    func updateImage()
}
class PickerViewController: UIViewController {
    
    weak var delegate: PickerDelegate?
    let pickerView = UIPickerView()
    var pickerViewValue = ["1", "2", "3", "4", "5", "6", "7", "8"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1))
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        setupPickerView()
    }
    override func viewWillAppear(_ animated: Bool) {
        pickerView.selectRow(Int(Metronome.topNum - 1), inComponent: 0, animated: true)
    }
    
    func setupPickerView() {
        view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -9),
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
}
extension PickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewValue.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Metronome.topNum = row + 1
        delegate?.updateImage()
        
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let pickerViewHeight: CGFloat = 300
        let numberOfVisibleRows: CGFloat = 3.2
        return pickerViewHeight / numberOfVisibleRows
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(row)
        
        return pickerViewValue[row]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 60, weight: .bold)
        label.text =  pickerViewValue[row]
        label.textColor = UIColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        label.textAlignment = .center
        return label
    }
}




