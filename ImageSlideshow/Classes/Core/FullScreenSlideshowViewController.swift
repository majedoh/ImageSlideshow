//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Majed Hariri
//

import UIKit

public protocol FullScreenSlideshowDelegate:AnyObject{
    func didPressEdit(currentImage : Int)
}


@objcMembers
open class FullScreenSlideshowViewController: UIViewController {
    
    public weak var delegate : FullScreenSlideshowDelegate?
    public var presentEdit : Bool = false
    public var presentDownlaod : Bool = false
    
    var messageLable : UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .white
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.text = "Edit"
        lab.layer.masksToBounds = false
        lab.layer.shadowColor = UIColor.black.cgColor
        lab.layer.shadowOpacity = 0.4
        lab.layer.shadowOffset = CGSize(width: 0, height: 0)
        lab.layer.shadowRadius = 1
        return lab
    }()
    
    var Holderview : UIControl = {
        let _view = UIControl()
        _view.backgroundColor = .clear
        return _view
    }()
    
    
    let generator = UIImpactFeedbackGenerator(style: .soft)
    var height : NSLayoutConstraint!
    var Downlaod_Control: UIControl = {
        let _view = UIControl()
        _view.backgroundColor = .clear
        _view.layer.cornerRadius = 8
        _view.alpha = 1
        _view.clipsToBounds = true
        _view.layer.borderWidth = 0.4
        _view.layer.borderColor = UIColor.white.cgColor
        return _view
    }()
    
    var Download_image: UIImageView = {
        let _ImageView = UIImageView()
        _ImageView.image = UIImage(named: "download")
        _ImageView.contentMode =  .scaleAspectFill
        _ImageView.backgroundColor = .clear
        _ImageView.clipsToBounds = true
        _ImageView.layer.masksToBounds = false
        _ImageView.layer.shadowColor = UIColor.black.cgColor
        _ImageView.layer.shadowOpacity = 0.4
        _ImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        _ImageView.layer.shadowRadius = 1
        return _ImageView
    }()
    
    var saveStatus : UILabel = {
        let lab = UILabel()
        lab.font = UIFont(name: "Dubai-Regular", size: 16)
        lab.text = "21 April 2022 - 01:50 PM"
        lab.numberOfLines = 1
        lab.textColor = #colorLiteral(red: 1, green: 1, blue: 0.9999999404, alpha: 1)
        lab.textAlignment = .center
        lab.alpha = 0.8
        lab.layer.cornerRadius = 4
        lab.clipsToBounds = true
        return lab
    }()
    
    

    open var slideshow: ImageSlideshow = {
        let slideshow = ImageSlideshow()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        // turns off the timer
        slideshow.slideshowInterval = 0
        slideshow.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        return slideshow
    }()

    /// Close button
    open var closeButton = UIButton()

    /// Close button frame
    open var closeButtonFrame: CGRect?

    /// Closure called on page selection
    open var pageSelected: ((_ page: Int) -> Void)?

    /// Index of initial image
    open var initialPage: Int = 0

    /// Input sources to
    open var inputs: [InputSource]?

    /// Background color
    open var backgroundColor =  UIColor(#colorLiteral(red: 0.1058823529, green: 0.1098039216, blue: 0.1411764706, alpha: 1))

    /// Enables/disable zoom
    open var zoomEnabled = true {
        didSet {
            slideshow.zoomEnabled = zoomEnabled
        }
    }

    fileprivate var isInit = true

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .custom
        if #available(iOS 13.0, *) {
            // Use KVC to set the value to preserve backwards compatiblity with Xcode < 11
            self.setValue(true, forKey: "modalInPresentation")
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        slideshow.backgroundColor = backgroundColor

        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }

        view.addSubview(slideshow)

        closeButton.layer.masksToBounds = false
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOpacity = 0.4
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        closeButton.layer.shadowRadius = 1
        
        // close button configuration
        closeButton.setImage(UIImage(named: "ic_cross_white", in: .module, compatibleWith: nil), for: UIControlState())
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), for: UIControlEvents.touchUpInside)
        view.addSubview(closeButton)
        
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrage(_:))))
        
        generator.prepare()
        
        
        if presentDownlaod{
            view.addSubview(Downlaod_Control)
            Downlaod_Control.addSubview(Download_image)
            
            Downlaod_Control.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                Downlaod_Control.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                Downlaod_Control.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                Downlaod_Control.heightAnchor.constraint(equalToConstant: 35),
                Downlaod_Control.widthAnchor.constraint(equalToConstant: 35)
            ])
            
            Download_image.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                Download_image.topAnchor.constraint(equalTo: Downlaod_Control.topAnchor, constant: 8),
                Download_image.bottomAnchor.constraint(equalTo: Downlaod_Control.bottomAnchor, constant: -8),
                Download_image.leadingAnchor.constraint(equalTo: Downlaod_Control.leadingAnchor, constant: 8),
                Download_image.trailingAnchor.constraint(equalTo: Downlaod_Control.trailingAnchor, constant: -8),
            ])
            
            Downlaod_Control.addTarget(self, action: #selector(saveImage), for: .touchDown)
            
            
            view.addSubview(saveStatus)
            saveStatus.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                saveStatus.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                saveStatus.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                saveStatus.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            ])
            height = saveStatus.heightAnchor.constraint(equalToConstant: 0)
            height.isActive = true
        }

        
        
        if presentEdit {
            view.addSubview(Holderview)
            Holderview.addSubview(messageLable)
            Holderview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                Holderview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                Holderview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                Holderview.widthAnchor.constraint(equalToConstant: 50),
                Holderview.heightAnchor.constraint(equalToConstant: 30),
            ])
            messageLable.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                messageLable.topAnchor.constraint(equalTo: Holderview.topAnchor, constant: 4),
                messageLable.bottomAnchor.constraint(equalTo: Holderview.bottomAnchor, constant: -4),
                messageLable.leadingAnchor.constraint(equalTo: Holderview.leadingAnchor, constant: 4),
                messageLable.trailingAnchor.constraint(equalTo: Holderview.trailingAnchor, constant: -4),
            ])
            Holderview.addTarget(self, action: #selector(didPressEdits), for: .touchDown)
        }
        
    }
    
    @objc func didPressEdits(){
        delegate?.didPressEdit(currentImage: slideshow.currentPage)
    }
    
    @objc func saveImage(){
        generator.impactOccurred()
        let imgage = UIImageView()
        if let inputs = inputs {
            inputs[slideshow.currentPage].load(to: imgage) { [self] image in
                guard let i : UIImage = image else {return}
                UIImageWriteToSavedPhotosAlbum(i, self, #selector(saveError), nil)
            }
        }
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            saveStatus.text = "Error: \(error)"
            saveStatus.backgroundColor = #colorLiteral(red: 1, green: 0.3098039216, blue: 0.2666666667, alpha: 0.9)
            presnetStatues()
        } else {
            saveStatus.text = "Saved Successfully"
            saveStatus.backgroundColor = #colorLiteral(red: 0.2348545492, green: 0.7098160386, blue: 0.4386150837, alpha: 0.9)
            presnetStatues()
        }
    }
    
    func presnetStatues(){
        dismissStatus()

        height.isActive = false
        height = saveStatus.heightAnchor.constraint(equalToConstant: 40)
        
        UIView.animate(withDuration: 0.4, animations: { [self] in
            height.isActive = true
            view.layoutIfNeeded()
        })
    }
    
    func dismissStatus(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: { [self] in
            height.isActive = false
            height = saveStatus.heightAnchor.constraint(equalToConstant: 0)
            UIView.animate(withDuration: 0.4, animations: { [self] in
                height.isActive = true
                view.layoutIfNeeded()
            })
            
        })
    }

    override open var prefersStatusBarHidden: Bool {
        return true
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isInit {
            isInit = false
            slideshow.setCurrentPage(initialPage, animated: false)
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        slideshow.slideshowItems.forEach { $0.cancelPendingLoad() }

        // Prevents broken dismiss transition when image is zoomed in
        slideshow.currentSlideshowItem?.zoomOut()
    }

    open override func viewDidLayoutSubviews() {
        if !isBeingDismissed {
            let safeAreaInsets: UIEdgeInsets
            if #available(iOS 11.0, *) {
                safeAreaInsets = view.safeAreaInsets
            } else {
                safeAreaInsets = UIEdgeInsets.zero
            }

            closeButton.frame = closeButtonFrame ?? CGRect(x: max(10, safeAreaInsets.left), y: max(10, safeAreaInsets.top), width: 40, height: 40)
        }

        slideshow.frame = view.frame
    }

    func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(slideshow.currentPage)
        }

        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Swipe to dismiss
    @objc func onDrage(_ gesture: UIPanGestureRecognizer) {
        let percent = max(0, gesture.translation(in: view).y) / view.frame.height
        switch gesture.state {
        case .began:
            let tran = gesture.translation(in: view)
            self.view.frame.origin.y = tran.y
            self.view.frame.origin.x = 0
            
        case .changed:
            let tran = gesture.translation(in: view)
            self.view.frame.origin.x = 0
            if tran.y < 0 {
                self.view.frame.origin.y = 0
            }else{
                self.view.frame.origin.y = tran.y
            }
            
        case .ended:
            let velocity = gesture.velocity(in: view).y
            if percent > 0.4 || velocity > 1000 {
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame.origin = CGPoint(x: 0, y: 0)
                })
                
            }
        case .cancelled, .failed:
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame.origin = CGPoint(x: 0, y: 0)
            })
            
        default:break
        }
        
    }
    
}
