//
//  AlbumViewController.swift
//  CarPlayer
//
//  Created by Peter Störmer on 27.11.14.
//  Copyright (c) 2014 Tempest Rock Studios. All rights reserved.
//

import UIKit
import MediaPlayer



class AlbumViewController: BasicViewController, UIScrollViewDelegate {

    // ----- Attributes ----------------

    // A flag that says whether or not a letter list makes sense:
    var _letterLineMakesSense: Bool = false


    // ----- Constants ----------------

    let _minNumForLetterLine: Int = 5


    // ----- Methods ----------------

    override func viewDidLoad() {
        super.viewDidLoad()

        // DEBUG print("AlbumViewController.viewDidLoad()")

        // Set cool background color:
        view.backgroundColor = UIColor.black

        createScrollview()

        if _letterLineMakesSense {

            createLetterLine()
        }
    }


    //
    // This handler is called whenever this view becomes visible.
    //
    override func viewDidAppear(_ animated: Bool) {

        // DEBUG print("AlbumViewController.viewDidAppear()")

        // Tell the controller about this:
        _controller.setCurrentlyVisibleView(view: self)

        if _controller.thisWasADirectJump() {

            // Directly hand over to the player view:
            performSegue(withIdentifier: MyBasics.nameOfSegue_albumToPlayer, sender: self)
        }
    }


    //
    // Creates the scroll view that contains the albums of the currently selected artist.
    //
    func createScrollview()
    {
        let widthOfEntry = MyBasics.ArtWork_Width
        let heightOfEntry = MyBasics.ArtWork_Height
        let yPos = MyBasics.ArtWork_YPos
        var xPos = MyBasics.ArtWork_InitialXPos
        let xGap = MyBasics.ArtWork_InitialXPos

        // Get the album ID list of the current artist. If the current artist is actually the "Playlists", then
        // the albumIDList contains the IDs of the playlists. But this is hidden inside _controller.
        let albumIDlist = _controller.albumIDListOfCurrentArtist()

        // Define a possibly used "play all" button:
        var playAllButton: UIButtonWithFeatures! = nil

        // Counter for the total number of tracks:
        var totalTrackNum: Int = 0

        if _controller.playingAllTracksForCurrentArtistMakesSense() {

            // There is more than one album to be selected.
            playAllButton = UIButtonWithFeatures(type: UIButtonType.system)
            createPlayAllButton(button: playAllButton, x: xPos, y: yPos, width: widthOfEntry, height: heightOfEntry)
            xPos += (widthOfEntry + xGap)
        }

        // For the letter list collection:
        var previousLetter: Character = "Z"
        _letterLineMakesSense = (albumIDlist.count >= _minNumForLetterLine)

        for albumID in albumIDlist {

            var albumName: String
            var artwork: MPMediaItemArtwork?        // May be nil if no artwork is available
            var numOfTracks: Int

            (albumName, artwork, numOfTracks) = _controller.getAlbumData(albumID: albumID)
            totalTrackNum += numOfTracks

            // Make a button:
            let button = UIButton(type: UIButtonType.system)
            button.titleLabel!.font = MyBasics.fontForSmallText
            button.frame = CGRect(x:CGFloat(xPos), y:CGFloat(yPos), width:CGFloat(widthOfEntry), height:CGFloat(heightOfEntry))

            if artwork != nil {

                // An image for the album does exist.

                let sizeOfAlbumImage = CGSize(width: artwork!.imageCropRect.width, height: artwork!.imageCropRect.height)
           //     var uiImage = artwork!.imageWithSize(sizeOfAlbumImage)
                button.setBackgroundImage(artwork!.image(at: sizeOfAlbumImage), for: .normal)

            } else {

                // No image. => Create some colorful button as no artwork exists.

                button.backgroundColor = UIColor.randomDarkColor()
                button.titleLabel!.font = MyBasics.fontForHugeText
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                button.setTitle(">", for: UIControlState.normal)
            }

            // Create two tap gesture recognizers that are attached to the button:
            let singleTap = UITapGestureRecognizerWithFeatures(target: self,
                                                               action: #selector(AlbumViewController.albumButtonTapped(gestureRecognizer:)))
            singleTap.numberOfTapsRequired = 1
            singleTap.setPlayAllButtonPressed(pressed: false)
            singleTap.setAlbumID(id: albumID)
            singleTap.setButtonIBelongTo(button: button)
            button.addGestureRecognizer(singleTap)

            let doubleTap = UITapGestureRecognizerWithFeatures(target: self,
                                                               action: #selector(AlbumViewController.albumButtonDoubleTapped(gestureRecognizer:)))
            doubleTap.numberOfTapsRequired = 2
            doubleTap.setPlayAllButtonPressed(pressed: false)
            doubleTap.setAlbumID(id: albumID)
            doubleTap.setButtonIBelongTo(button: button)
            button.addGestureRecognizer(doubleTap)

            // Ignore the single tap if the user tapped twice (that's the secret ingredient! ;)
            singleTap.require(toFail: doubleTap)
            
            _scrollView.addSubview(button)

            // Create the caption for the album button:
            let albumCaption = albumName + " (" + numOfTracks.description + ")"

            // Create a label for the number of tracks in this album:
            let trackNumLabel = UILabel()
            trackNumLabel.text = albumCaption
            trackNumLabel.font = MyBasics.fontForVerySmallText
            trackNumLabel.textColor = UIColor.white
            trackNumLabel.textAlignment = NSTextAlignment.center
            trackNumLabel.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
            trackNumLabel.frame = CGRect(x:CGFloat(xPos), y:CGFloat(yPos+heightOfEntry+4), width:CGFloat(widthOfEntry), height:14.0)
            _scrollView.addSubview(trackNumLabel)

            // Get the first letter out of the artist name:
            let firstLetter = Array(albumName.characters)[0] as Character
            if firstLetter != previousLetter {

                // The found letter is different to the on of the previous artist name.
                // --> Store the position of the found letter.
                _letterToPos[firstLetter] = CGFloat(xPos-10)
                previousLetter = firstLetter
            }

            // Step over to the next entry x position:
            xPos += (widthOfEntry + xGap)
        }

        if playAllButton != nil {

            // Create a label for the total number of tracks at the "play all" button:
            let trackNumLabel = UILabel()
            trackNumLabel.text = totalTrackNum.description
            trackNumLabel.font = MyBasics.fontForVerySmallText
            trackNumLabel.textColor = UIColor.white
            trackNumLabel.textAlignment = NSTextAlignment.center
            trackNumLabel.frame = CGRect(x:CGFloat(MyBasics.ArtWork_InitialXPos), y:CGFloat(yPos+heightOfEntry+4), width:CGFloat(widthOfEntry), height:14.0)
            _scrollView.addSubview(trackNumLabel)
        }

        // Adjust the size of the scroll view:
        _scrollView.contentSize = CGSize(width:CGFloat(xPos), height:CGFloat(heightOfEntry / 2))
//        _scrollView.frame = CGRect(origin: CGPoint(x: 0, y: 0),
  //          size: CGSize(width: CGFloat(MyBasics.screenWidth), height: CGFloat(heightOfEntry + MyBasics.ArtWork_YPos)))
    }


    //
    // Creates the play button that can be used to play all albums at once.
    //
    func createPlayAllButton(button: UIButtonWithFeatures, x: Int, y: Int, width: Int, height: Int) {

        button.titleLabel!.font = MyBasics.fontForHugeText
        button.frame = CGRect(x:CGFloat(x), y:CGFloat(y), width:CGFloat(width), height:CGFloat(height))
        button.backgroundColor = UIColor.randomDarkColor()
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.setTitle(">", for: UIControlState.normal)

        // Create two tap gesture recognizers that are attached to the button:
        let singleTap = UITapGestureRecognizerWithFeatures(target: self,
                                                           action: #selector(AlbumViewController.albumButtonTapped(gestureRecognizer:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.setPlayAllButtonPressed(pressed: true)
        singleTap.setButtonIBelongTo(button: button)
        button.addGestureRecognizer(singleTap)

        let doubleTap = UITapGestureRecognizerWithFeatures(target: self,
                                                           action: #selector(AlbumViewController.albumButtonDoubleTapped(gestureRecognizer:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.setPlayAllButtonPressed(pressed: true)
        doubleTap.setButtonIBelongTo(button: button)
        button.addGestureRecognizer(doubleTap)

        // Ignore the single tap if the user tapped twice (that's the secret ingredient! ;)
        singleTap.require(toFail: doubleTap)

        _scrollView.addSubview(button)
    }


    //
    // Handles the case that an album has been selected by the user.
    // The view is switched to the PlayerViewController.
    // The button may also be the "play all" button.
    //
    func albumButtonTapped(gestureRecognizer: UITapGestureRecognizerWithFeatures) {

        // DEBUG print("AlbumViewController.albumButtonTapped()")

        UIView.animateSlightShrink(
            itemToShrink: gestureRecognizer.buttonIBelongTo(),
            completion: { finished in
                self.setUserSelection(gestureRecognizer: gestureRecognizer, isShuffled: false)
        })
    }


    //
    // Handles the case that an album has been selected by the user by double-tapping
    //
    func albumButtonDoubleTapped(gestureRecognizer: UITapGestureRecognizerWithFeatures) {

        // DEBUG print("AlbumViewController.albumButtonDoubleTapped()")

        UIView.animateStrongShake(
            itemToShake: gestureRecognizer.buttonIBelongTo(),
            completion: { finished in
                self.setUserSelection(gestureRecognizer: gestureRecognizer, isShuffled: true)
        })
    }
    
    
    //
    // Tells the controller about the user's selection
    // Switches over to the PlayerViewController.
    //
    func setUserSelection(gestureRecognizer: UITapGestureRecognizerWithFeatures, isShuffled: Bool) {

        // Create the album ID list to be played (even if it is only one album):
        var albumIDList: Array<NSNumber>

        if gestureRecognizer.playAllButtonPressed() {

            // All albums are to be played:
            albumIDList = _controller.albumIDListOfCurrentArtist()

        } else {

            // Only one album to be played:
            albumIDList = Array<NSNumber>()
            albumIDList.append(gestureRecognizer.albumID())

        }

        // Tell the controller which album has been chosen:
        _controller.setCurrentAlbumIDList(albumIDList: albumIDList, setShuffleMode: isShuffled)

        performSegue(withIdentifier: MyBasics.nameOfSegue_albumToPlayer, sender: self)
    }





    //
    // This handler is called when the user has swiped up on the main view.
    // If music is currently playing, this leads to the PlayerViewController.
    //
    @IBAction func userHasSwipedUp(sender: UISwipeGestureRecognizer) {

        if !_controller.nowPlayingItemExists() {

            // Nothing to be done here.
            return
        }

        // Store in the contoller the information that a direct jump to the player is intended:
        _controller.setFlagOfDirectJump()

        // Switch over to the player view:
        performSegue(withIdentifier: MyBasics.nameOfSegue_albumToPlayer, sender: self)
    }


    @IBAction func unwindToViewController (sender: UIStoryboardSegue){

        // DEBUG print("AlbumViewController.unwindToViewController()")
    }
    
    
    //
    // Handles the users pinching which changes the brightness of the screen.
    //
    @IBAction func userHasPinched(sender: UIPinchGestureRecognizer) {

        _controller.setBrightness(pinchScale: sender.scale)
    }


    //
    // This function is called shortly before a switch from this view to another.
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // DEBUG print("AlbumViewController.prepareForSegue()")

        if segue.identifier == MyBasics.nameOfSegue_albumToPlayer {

            // DEBUG print("AlbumView --> PlayerView")

            // this gets a reference to the screen that we're about to transition to
            let playerView = segue.destination as! PlayerViewController

            // Instead of using the default transition animation, we'll ask
            // the segue to use our custom TransitionManager object to manage the transition animation:
            playerView.transitioningDelegate = _rotatingTransition
        }
    }
}
