//
//  PasswordTextField.swift
//  CustomPasswordTextField
//
//  Created by 김종권 on 2021/01/07.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class PasswordTextField: UITextField {

    enum CurrentPasswordInputStatus {
        case invalidPassword
        case validPassword
    }

    private var rightButton: UIButton!
    private let bag = DisposeBag()
    private var currentPasswordInputStatus: CurrentPasswordInputStatus = .invalidPassword
    let textResetEvent = PublishSubject<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        delegate = self
        rightButton = UIButton()
        rightButton.contentMode = .scaleAspectFit
        rightButton.setImage(UIImage(named: "open_eye"), for: .normal)
        rightView = rightButton
        rightViewMode = .always
        leftViewMode = .never

        rightButton.rx.tap.asDriver{ _ in .never() }
            .drive(onNext: { [weak self] in
                self?.updateCurrentStatus()
            }).disposed(by: bag)
    }

    private func updateCurrentStatus() {
        isSecureTextEntry.toggle()
        if isSecureTextEntry {
            rightButton.setImage(UIImage(named: "open_eye"), for: .normal)
        } else {
            rightButton.setImage(UIImage(named: "close_eye"), for: .normal)
        }
    }

    // MARK: - Public

    public func setupValidStatus() {
        textColor = .black
        currentPasswordInputStatus = .validPassword
    }

    public func setupInvalidStatus() {
        textColor = .red
        currentPasswordInputStatus = .invalidPassword
    }
}

extension PasswordTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if string.isEmpty, currentPasswordInputStatus == .invalidPassword {
            textField.text = ""
            setupValidStatus()
            textResetEvent.onNext(())
            return false
        }
        return true
    }
}
