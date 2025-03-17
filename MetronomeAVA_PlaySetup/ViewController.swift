//
//  ViewController.swift
//  MetronomeAVA_PlaySetup
//
//  Created by Андрей Андриянов on 03.11.2024.
//

import UIKit

class ViewController: UIViewController, PickerDelegate {
    
    var metronome = Metronome()
    let pickerView = UIPickerView()
    var slider = UISlider()
    var pickerData: [String] = []
    var lastTapTime: TimeInterval?
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var beatImageArray: [UIImageView] = [
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView(),
        createImageView()
    ]
    func addArrageSubviews() {
        stackView.addArrangedSubview(beatImageArray[0])
        stackView.addArrangedSubview(beatImageArray[1])
        stackView.addArrangedSubview(beatImageArray[2])
        stackView.addArrangedSubview(beatImageArray[3])
        stackView.addArrangedSubview(beatImageArray[4])
        stackView.addArrangedSubview(beatImageArray[5])
        stackView.addArrangedSubview(beatImageArray[6])
        stackView.addArrangedSubview(beatImageArray[7])
    }
    let fillBitImage = UIImage(systemName: "stop.fill")
    let bitImage = UIImage(systemName: "stop")
    
    func createImageView() -> UIImageView {
        let imageView = UIImageView(image: bitImage)
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.tintColor = UIColor(#colorLiteral(red: 0.6155465245, green: 0.596773684, blue: 0.5478830338, alpha: 1))
        return imageView
    }
    
    var timeSignButton: UIButton = {
        let timeSignButton = UIButton()
        timeSignButton.backgroundColor = UIColor(#colorLiteral(red: 0.6155465245, green: 0.596773684, blue: 0.5478830338, alpha: 1))
        timeSignButton.tintColor = .systemGray
        timeSignButton.setTitle("4/4", for: .normal)
        timeSignButton.layer.cornerRadius = 10
        timeSignButton.isHighlighted = true
        timeSignButton.translatesAutoresizingMaskIntoConstraints = false
        return timeSignButton
    }()
    
    var startButton: UIButton = {
        let startButton = UIButton()
        startButton.backgroundColor = .systemGreen
        startButton.tintColor = .systemGray
        startButton.setTitle("START", for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.isHighlighted = true
        startButton.translatesAutoresizingMaskIntoConstraints = false
        return startButton
    }()
    
    var tapTempoButton: UIButton = {
        let tapTempoButton = UIButton()
        tapTempoButton.backgroundColor = UIColor(#colorLiteral(red: 0.6155465245, green: 0.596773684, blue: 0.5478830338, alpha: 1))
        tapTempoButton.tintColor = .systemGray
        tapTempoButton.setTitle("TAP", for: .normal)
        tapTempoButton.layer.cornerRadius = 10
        tapTempoButton.isHighlighted = true
        tapTempoButton.translatesAutoresizingMaskIntoConstraints = false
        return tapTempoButton
    }()
    
    var mainImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        setupImageView()
        setConstraints()
        
        pickerView.backgroundColor = .lightGray
        pickerView.alpha = 0.9
        pickerView.layer.cornerRadius = 80
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        setSliderDefault()
        
        addArrageSubviews()
        
        pickerView.selectRow(Int(slider.value - 20), inComponent: 0, animated: true)
        
        startButton.addTarget(self, action: #selector(startButtonAction), for: .touchUpInside)
        timeSignButton.addTarget(self, action: #selector(timeSignButtonAction), for: .touchUpInside)
        tapTempoButton.addTarget(self, action: #selector(tapTempoButtonAction), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderChangedBpm), for: .allEvents)
        
        self.updateBeatImage(Metronome.topNum)
        
        metronome.dataForAnimate = { (interval) in
            self.cancelBeatImageAnimation()
            self.animateBeatImage()
        }
    }
    
    func setupImageView() {
        view.addSubview(mainImageView)
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: view.topAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setSliderDefault() {
        slider.tintColor = UIColor(#colorLiteral(red: 0.3821307421, green: 0.3722137213, blue: 0.3333640099, alpha: 1))
        slider.thumbTintColor = UIColor(#colorLiteral(red: 0.3801537156, green: 0.2612983584, blue: 0, alpha: 1))
        slider.maximumTrackTintColor = UIColor(#colorLiteral(red: 0.6155465245, green: 0.596773684, blue: 0.5478830338, alpha: 1))
        slider.minimumValue = metronome.minBpm
        slider.maximumValue = metronome.maxBpm
        slider.value = metronome.bpm
    }
    
    @objc func sliderChangedBpm() {
        metronome.bpm = slider.value
        DispatchQueue.main.async {
            self.pickerView.selectRow(Int(self.slider.value - 20), inComponent: 0, animated: true)
        }
    }
    
    @objc func startButtonAction() {
        self.cancelBeatImageAnimation()
        if metronome.isRunning == true {
            metronome.isRunning = false
            startButton.backgroundColor = .systemGreen
            startButton.setTitle("START", for: .normal)
        } else {
            metronome.isRunning = true
            startButton.backgroundColor = .systemRed
            startButton.setTitle("STOP", for: .normal)
        }
    }
    
    @objc func timeSignButtonAction() {
        let pickerViewController = PickerViewController()
        pickerViewController.delegate = self
        if let sheet = pickerViewController.sheetPresentationController {
            sheet.detents = [ .medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 80
        }
        present(pickerViewController, animated: true)
    }
    
    @objc func tapTempoButtonAction() {
        let currentTime = Date().timeIntervalSince1970
        if let lastTap = lastTapTime {
            let interval = currentTime - lastTap

            if interval > 2 {
                metronome.saveTapTime.removeAll()
                print("Tap times reset")
            }
        } else {
            print("First tap")
        }
        lastTapTime = currentTime
        metronome.saveTapTime.append(currentTime)
        guard metronome.saveTapTime.count >= 2 else { return }
        metronome.calculateTap()
        self.slider.value  = self.metronome.bpm
        self.pickerView.selectRow(Int(self.slider.value - 20), inComponent: 0, animated: true)  
    }
    
    func updateImage() {
        updateBeatImage(Metronome.topNum)
        timeSignButton.setTitle("\(Metronome.topNum)/4", for: .normal)
    }
    
    func updateBeatImage(_ topNum: Int) {
        for i in 0...7 {
            beatImageArray[i].isHidden = i < topNum ? false : true
        }
    }
    
    func animateBeatImage() {
        for i in 0..<Metronome.topNum {
            beatImageArray[i].image = bitImage
            beatImageArray[Metronome.totalBeat].image = fillBitImage
        }
        Metronome.totalBeat += 1
        if Metronome.totalBeat >= Metronome.topNum {
            Metronome.totalBeat = 0
        }
    }
   
    func cancelBeatImageAnimation() {
        for i in 0...7 {
            beatImageArray[i].image = bitImage
        }
    }
    
    func setConstraints() {
        view.addSubview(stackView)
        view.addSubview(pickerView)
        view.addSubview(slider)
        view.addSubview(startButton)
        view.addSubview(timeSignButton)
        view.addSubview(tapTempoButton)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -9),
            pickerView.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -50),
            
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 30),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            startButton.widthAnchor.constraint(equalToConstant: 150),
            
            timeSignButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeSignButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),
            timeSignButton.heightAnchor.constraint(equalToConstant: 60),
            timeSignButton.widthAnchor.constraint(equalToConstant: 60),
            
            tapTempoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tapTempoButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor),
            tapTempoButton.heightAnchor.constraint(equalToConstant: 60),
            tapTempoButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData = (Int(20)...Int(200)).map { String($0) }
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        let pickerViewHeight: CGFloat = 150
        let numberOfVisibleRows: CGFloat = 2
        return pickerViewHeight / numberOfVisibleRows
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        slider.value = Float(row + 20)
        metronome.bpm = Float(row + 20)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let view = view as? UILabel { label = view }
        label.font = .systemFont(ofSize: 60, weight: .bold)
        label.text =  pickerData[row]
        label.textColor = UIColor(#colorLiteral(red: 0.1340290308, green: 0.1086466387, blue: 4.684161468e-05, alpha: 1))
        label.alpha = 0.9
        label.textAlignment = .center
        return label
    }
}




