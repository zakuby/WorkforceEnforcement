//
//  API.swift
//  workforce
//
//  Created by admin on 7/28/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Foundation
import AlamofireObjectMapper
import Alamofire
import ObjectMapper

class APIManager{
    static let sharedAPI = APIManager()
    
    func getTopViewController() -> UIViewController?{
        if var topController = UIApplication.shared.keyWindow?.rootViewController
        {
            while (topController.presentedViewController != nil)
            {
                topController = topController.presentedViewController!
            }
            return topController
        }
        return nil
    }
    
    
    func handleForgotPass(email: String){
        let emailParameter: Parameters = [
            "email_target": email
        ]
        Alamofire.request("http://staging.api.workforce.id/api/v1/user/forgotPassword", method: .post, parameters: emailParameter).responseObject { (response : DataResponse<forgotPass>) in
            let responseMsg = response.result.value
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                self.createAlert(titleText: "Succes", messageText: (responseMsg?.message)!)
            }else{
                self.createAlert(titleText: "Failure", messageText: (responseMsg?.status)!)
            }
        }
    }
    
    
    func handleLogin(email: String, password: String){
        
        guard let parameters: Parameters = [
            "Email": email,
            "Password": password
            ]
            else{
                return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tabBarLog")
        
        Alamofire.request("http://staging.api.workforce.id/api/v1/user/login", method: .post, parameters: parameters).responseObject{ (response : DataResponse<User>) in
            let user = response.result.value
            let JSONString = user?.toJSONString(prettyPrint: true)
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                UserDefaults.standard.set(JSONString, forKey: "userData")
                UserDefaults.standard.synchronize()
                
                self.getTopViewController()?.present(vc, animated: true, completion: nil)
                
            }else{
                self.handleLoginError(user: user)
            }
        }
    }
    
    func attendanceReport(token: String, year: String, month: String, completeonClosure: @escaping (attendeList) -> Void){
        
        let parameters: Parameters = [
            "token": token,
            "Page": 1,
            "PageLimit": 30,
            "Search[0][field]": "date",
            "Search[0][condition]": "between",
            "Search[0][value1]": year + "-" + month + "-01",
            "Search[0][value2]": year + "-" + month + "-31"
        ]
        
        Alamofire.request("http://staging.api.workforce.id/api/v1/attendance/manageoutgoingrequest", method: .post, parameters: parameters).responseObject{ (response : DataResponse<attendeList>) in
            let user = response.result.value
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                completeonClosure(user!)
            }else{
                return
            }
        }
        
    }
    
    func handleLoginError(user: User?){
        if user?.passMessage != nil && user?.emailMessage != nil{
            createAlert(titleText: "Login Failure", messageText: (user?.status)! + "\n" + (user?.emailMessage)! + "\n" + (user?.passMessage)!)
        }else if user?.emailMessage != nil {
            createAlert(titleText: "Login Failure", messageText: (user?.status)! + "\n" + (user?.emailMessage)!)
        }else if user?.passMessage != nil{
            createAlert(titleText: "Login Failure", messageText: (user?.status)! + "\n" + (user?.passMessage)!)
        }else{
            createAlert(titleText: "Login Failure", messageText: (user?.status)!)
        }
    }
    
    func createAlert(titleText: String, messageText: String){
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        let cancelOption = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        cancelOption.setValue(UIColor.init(red: 42/255, green: 147/255, blue: 137/255, alpha: 1), forKey: "titleTextColor")
        alert.addAction(cancelOption)
        
        self.getTopViewController()?.present(alert, animated: true, completion:  nil)
    }
}
