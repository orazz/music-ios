//
//  CaptchaNeededVC.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/11/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit

class CaptchaNeededVC: UIViewController {
    
    @IBOutlet weak var newCaptchaImgBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var captchaImg: UIImageView!
    @IBOutlet weak var captchaCodeFromImg: UITextField!
    var captchaImgUrl = ""
    var captcha_sid = ""
    var api : APIController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let escpaedurl = captchaImgUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        ImageLoader.sharedLoader.imageForUrl(escpaedurl!, completionHandler: {(image: UIImage?, url: String) in
            if image != nil {
                self.captchaImg.image = image
                self.newCaptchaImgBtn.enabled = true
                self.sendBtn.enabled = true
            }
        })
    }
    
    @IBAction func SendCaptcha(sender: UIButton) {
        api = APIController(delegate: self)
        api!.captchaWrite(captcha_sid, captcha_key: captchaCodeFromImg.text)
    }
    
    @IBAction func newCaptchaImg(sender: AnyObject) {
        let escpaedurl = captchaImgUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        ImageLoader.sharedLoader.imageForUrl(escpaedurl!, completionHandler: {(image: UIImage?, url: String) in
            if image != nil {
                self.captchaImg.image = image
                self.newCaptchaImgBtn.enabled = true
                self.sendBtn.enabled = true
            }
        })
    }
}

extension CaptchaNeededVC: APIControllerProtocol {
    
    func didReceiveAPIResults(results: NSDictionary, indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
