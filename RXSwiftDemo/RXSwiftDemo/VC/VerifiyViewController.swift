//
//  VerifiyViewController.swift
//  RXSwiftDemo
//
//  Created by admin on 14/08/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VerifiyViewController: BaseViewController {

    @IBOutlet weak var userNmae: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var doBtn: UIButton!
    
    @IBOutlet weak var pwd_tips: UILabel!
    
    @IBOutlet weak var user_tips: UILabel!
    var disposeBag : DisposeBag = DisposeBag.init()


    let minimalUsernameLength = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user_tips.text = "Username has to be at least \(minimalUsernameLength) characters"
        pwd_tips.text = "Password has to be at least \(minimalUsernameLength) characters"

        //监听输入用户名是否有效
        
        let usernameValid = userNmae.rx.text.orEmpty.map {$0.count >= self.minimalUsernameLength}.share(replay:1)
        
        //密码是否有效
        let passwordValid = password.rx.text.orEmpty.map{$0.count >= self.minimalUsernameLength}.share(replay: 1)
        
        //合并两个信号
        let everythingValid = Observable.combineLatest(usernameValid, passwordValid) { ($0 && $1) }.share(replay: 1)
        
        
        //用户名是否有效 -> 绑定到密码输入框是否有用
        usernameValid.bind(to: password.rx.isEnabled).disposed(by: disposeBag)

        usernameValid.bind(to: user_tips.rx.isHidden).disposed(by: disposeBag)
        
        passwordValid.bind(to: pwd_tips.rx.isHidden).disposed(by: disposeBag)
      
        everythingValid.bind(to: doBtn.rx.isEnabled).disposed(by: disposeBag)
        
        doBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.showAlert()
        }).disposed(by: disposeBag)
    }

    
    func showAlert() -> Void {
        let alertVC = UIAlertController.init(title: "提示", message: "", preferredStyle: .alert)
        let sureAction = UIAlertAction.init(title: "sure", style: .default) { (alertAction) in
            
        }
        alertVC.addAction(sureAction)
        self.present(alertVC, animated: true, completion: nil);
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
