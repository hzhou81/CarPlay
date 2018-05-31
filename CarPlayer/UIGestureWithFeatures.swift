//
//  UIGestureWithFeatures.swift
//  CarPlayer
//
//  Created by Peter Störmer on 20.12.14.
//  Copyright (c) 2014 Tempest Rock Studios. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit


//
// An enhanced UITapGestureRecognizer class that has some more attributes.
// These attributes are used to be handed over as data when a gesture recognizer fires.
//
class UITapGestureRecognizerWithFeatures: UITapGestureRecognizer {

    var _playAllButtonPressed: Bool? = nil
    @objc var _albumID: NSNumber? = nil
    @objc var _buttonIBelongTo: UIButton? = nil


    @objc func setPlayAllButtonPressed(pressed: Bool) {

        _playAllButtonPressed = pressed
    }

    @objc func playAllButtonPressed() -> Bool {

        assert(_playAllButtonPressed != nil, "UITapGestureRecognizerWithFeatures.playAllButtonPressed(): flag not initialized")
        return _playAllButtonPressed!
    }

    @objc func setAlbumID(id: NSNumber) {

        _albumID = id
    }

    @objc func albumID() -> NSNumber {

        assert(_albumID != nil, "UITapGestureRecognizerWithFeatures.albumID(): ID not initialized")
        return _albumID!
    }

    @objc func setButtonIBelongTo(button: UIButton) {

        _buttonIBelongTo = button
    }

    @objc func buttonIBelongTo() -> UIButton {

        assert(_buttonIBelongTo != nil, "UITapGestureRecognizerWithFeatures.buttonIBelongTo(): button not initialized")
        return _buttonIBelongTo!
    }
}
