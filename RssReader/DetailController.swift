//
//  DetailController.swift
//  RssReader
//
//  Created by ysjjchh on 14-8-22.
//  Copyright (c) 2014年 ysjjchh. All rights reserved.
//

import UIKit
import MediaPlayer

protocol DetailControllerDataSource : NSObjectProtocol {
    func nextContent() -> String?
    func previousContent() -> String?
}

class DetailController : UIViewController, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate {

    var htmlContent:String?
    let _textView = DTAttributedTextView()
    var _mediaPlayers = [MPMoviePlayerController]()
    var delegate:DetailControllerDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.height -= 64;
        _textView.frame = self.view.bounds
        //_webView.scalesPageToFit = true
        self.view.addSubview(_textView)
        //_webView.editable = false
        _textView.shouldDrawImages = false
        _textView.textDelegate = self
        _textView.contentInset = UIEdgeInsetsMake(15, 10, 54, 10)
        
        let toolbar = RToolbar(frame: CGRectMake(0, self.view.height-37, 320, 37))
        self.view.addSubview(toolbar)
        toolbar.handler = { [weak self] index in
            if self!.delegate {
                switch index {
                case 0:
                    let content = self!.delegate!.nextContent()
                    if content {
                        self!.htmlContent = content!
                        self!.setContent()
                    }
                case 1:
                    let content = self!.delegate!.previousContent()
                    if content {
                        self!.htmlContent = content!
                        self!.setContent()
                    }
                default:
                    1
                }
            }

        }
        
        self.setContent()
    }
    
    func setContent() {
        _textView.contentOffsetY = 0
        
        let maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0)
        let attributed = NSAttributedString(HTMLData: htmlContent!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
            options:NSDictionary(dictionary: [DTUseiOS6Attributes:true,
                DTMaxImageSize:NSValue(CGSize:maxImageSize),
                DTDefaultFontSize:NSNumber(float: 16)]),
            documentAttributes: nil)

        _textView.attributedString = attributed
    }
    
    func lazyImageView(lazyImageView:DTLazyImageView, didChangeImageSize size:CGSize) {
        
        let url = lazyImageView.url
        let imageSize = size
        
        let pred = NSPredicate(format:"contentURL == %@", url)
        
        var didUpdate = false
        
        // update all attachments that matchin this URL (possibly multiple images with same size)
        let array = _textView.attributedTextContentView.layoutFrame.textAttachmentsWithPredicate(pred)
        for one in array
        {
            let oneAttachment = one as DTTextAttachment
            // update attachments that have no original size, that also sets the display size
            if CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero)
            {
                oneAttachment.originalSize = imageSize
                
                didUpdate = true
            }
        }
        
        if (didUpdate)
        {
        // layout might have changed due to image sizes
            _textView.relayoutText()
        }
    }
    
    func attributedTextContentView(attributedTextContentView:DTAttributedTextContentView,
        viewForAttachment attachment:DTTextAttachment,
        frame aframe:CGRect) -> UIView?
    {
        if attachment is DTVideoTextAttachment
        {
            let url = attachment.contentURL
        
        // we could customize the view that shows before playback starts
            let grayView = UIView(frame:aframe)
            grayView.backgroundColor = UIColor.blackColor()
            
            // find a player for this URL if we already got one
            var player:MPMoviePlayerController?
            for player in _mediaPlayers
            {
                if player.contentURL.isEqual(url)
                {
                    break;
                }
            }
        
            if !player
            {
                player = MPMoviePlayerController(contentURL:url)
                _mediaPlayers.append(player!)
            }
        
            if (UIDevice.currentDevice().systemVersion as NSString).floatValue > 4.3 {
                let airplayAttr = (attachment.attributes as NSDictionary)["x-webkit-airplay"] as String
                if airplayAttr == "allow"
                {
                    if player!.respondsToSelector("setAllowsAirPlay:")
                    {
                        player!.allowsAirPlay = true
                    }
                }
            }
            
            let controlsAttr = (attachment.attributes as NSDictionary)["controls"] as String?
            if controlsAttr
            {
                player!.controlStyle = .Embedded
            }
            else
            {
                player!.controlStyle = .None
            }
            
            let loopAttr = (attachment.attributes as NSDictionary)["loop"] as String?
            if loopAttr
            {
                player!.repeatMode = .One
            }
            else
            {
                player!.repeatMode = .None
            }
            
            let autoplayAttr = (attachment.attributes as NSDictionary)["autoplay"] as String?
            if autoplayAttr
            {
                player!.shouldAutoplay = true
            }
            else
            {
                player!.shouldAutoplay = false
            }
            
            player!.prepareToPlay()
            
            player!.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            player!.view.frame = grayView.bounds
            grayView.addSubview(player!.view)
        
            return grayView
        }
        else if attachment is DTImageTextAttachment
        {
            // if the attachment has a hyperlinkURL then this is currently ignored
            let imageView = DTLazyImageView(frame:aframe)
            imageView.delegate = self
            
            // sets the image if there is one
            imageView.image = (attachment as DTImageTextAttachment).image
            
            // url for deferred loading
            imageView.url = attachment.contentURL
            
            // if there is a hyperlink then add a link button on top of this image
            //if attachment.hyperLinkURL
            //{
                // NOTE: this is a hack, you probably want to use your own image view and touch handling
                // also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
                imageView.userInteractionEnabled = true
                
                let button = DTLinkButton(frame:imageView.bounds)
                button.URL = attachment.hyperLinkURL
                //button.minimumHitSize = aframe.size // adjusts it's bounds so that button is always large enough
                button.GUID = attachment.hyperLinkGUID
                button.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                
                // use normal push action for opening URL
                button.addTarget(self, action:"imagePushed:", forControlEvents:.TouchUpInside)
                
                // demonstrate combination with long press
//                let longPress = UILongPressGestureRecognizer(target:self, action:"linkLongPressed:")
//                button.addGestureRecognizer(longPress)
                
                imageView.addSubview(button)
            //}
            
            return imageView;
        }
        else if attachment is DTIframeTextAttachment
        {
            let videoView = DTWebVideoView(frame:aframe)
            videoView.attachment = attachment
            
            return videoView
        }
        else if attachment is DTObjectTextAttachment
        {
            // somecolorparameter has a HTML color
            let colorName = (attachment.attributes as NSDictionary)["somecolorparameter"] as String
            let someColor = DTColorCreateWithHTMLName(colorName)
            
            let someView = UIView(frame:aframe)
            someView.backgroundColor = someColor
            someView.layer.borderWidth = 1
            someView.layer.borderColor = UIColor.blackColor().CGColor
            
            someView.accessibilityLabel = colorName
            someView.isAccessibilityElement = true
            
            return someView
        }
        
        return nil
    }
    
    func imagePushed(button:DTLinkButton) {
        let imageView = button.superview as UIImageView
        
        let imageInfo = JTSImageInfo()
        imageInfo.image = imageView.image
        imageInfo.referenceRect = button.frame;
        imageInfo.referenceView = imageView.superview
        
        // Setup view controller
        let imageViewer = JTSImageViewController(imageInfo:imageInfo,
            mode:.Image,
            backgroundStyle:._ScaledDimmedBlurred)
        
        // Present the view controller.
        imageViewer.showFromViewController(self, transition:._FromOffscreen)
    }

}













