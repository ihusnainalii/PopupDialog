//
//  PopupDialog.swift
//
//  Copyright (c) 2016 Orderella Ltd. (http://orderella.co.uk)
//  Author - Martin Wildfeuer (http://www.mwfire.de)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

/// Creates a Popup dialog similar to UIAlertController
final public class PopupDialog<T: UIView>: UIViewController {

    // MARK: Private / Internal

    /// The custom transition presentation manager
    private let presentationManager: PopupDialogPresentationManager

    /// Returns the controllers view
    internal var popupContainerView: PopupDialogContainerView {
        return view as! PopupDialogContainerView
    }

    /// The set of buttons
    private var buttons = [PopupDialogButton]()

    // MARK: Public

    /// The content view of the popup dialog
    public var popupView: T

    // MARK: - Initializers

    /*!
     Creates a standard popup dialog with title, message and image field

     - parameter title:           The dialog title
     - parameter message:         The dialog message
     - parameter image:           The dialog image
     - parameter buttonAlignment: The dialog button alignment
     - parameter transitionStyle: The dialog transition style

     - returns: Popup dialog standard style
     */
    public convenience init(
                title: String?,
                message: String?,
                image: UIImage? = nil,
                buttonAlignment: UILayoutConstraintAxis = .Vertical,
                transitionStyle: PopupDialogTransitionStyle = .BounceUp) {

        // Create and configure the standard popup dialog view
        let view = PopupDialogView(frame: .zero)
        view.titleText = title
        view.messageText = message
        view.image = image

        // Call designated initializer
        self.init(view: view as! T, buttonAlignment: buttonAlignment, transitionStyle: transitionStyle)
    }

    /*!
     Creates a popup dialog containing a custom view

     - parameter view:      A custom view to be displayed
     - parameter buttonAlignment: The dialog button alignment
     - parameter transitionStyle: The dialog transition style

     - returns: Popup dialog with custom view
     */
    public init(
        view: T,
        buttonAlignment: UILayoutConstraintAxis = .Vertical,
        transitionStyle: PopupDialogTransitionStyle = .BounceUp) {

        presentationManager = PopupDialogPresentationManager(transitionStyle: transitionStyle)
        popupView = view

        super.init(nibName: nil, bundle: nil)

        // Define presentation styles
        transitioningDelegate = presentationManager
        modalPresentationStyle = .Custom

        // Add our custom view to the container
        popupContainerView.stackView.insertArrangedSubview(view, atIndex: 0)

        // Set button alignment
        popupContainerView.buttonStackView.axis = buttonAlignment
    }

    // Init with coder not implemented
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    /// Replaces controller view with popup view
    public override func loadView() {
        view = PopupDialogContainerView(frame: UIScreen.mainScreen().bounds)
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // FIXME: Make sure this is called only once
        appendButtons()
    }

    // MARK: - Button related

    /*!
     Appends the buttons added to the popup dialog
     to the placeholder stack view
     */
    private func appendButtons() {
        // Add action to buttons
        for (index, button) in buttons.enumerate() {
            button.needsLeftSeparator = popupContainerView.buttonStackView.axis == .Horizontal && index > 0
            popupContainerView.buttonStackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: .TouchUpInside)
        }
    }

    /*!
     Adds a single PopupDialogButton to the Popup dialog
     - parameter button: A PopupDialogButton instance
     */
    public func addButton(button: PopupDialogButton) {
        buttons.append(button)
    }

    /*!
     Adds an array of PopupDialogButtons to the Popup dialog
     - parameter buttons: A list of PopupDialogButton instances
     */
    public func addButtons(buttons: [PopupDialogButton]) {
        self.buttons += buttons
    }

    /// Calls the action closure of the button instance tapped
    @objc private func buttonTapped(button: PopupDialogButton) {
        dismissViewControllerAnimated(true) {
            button.buttonAction?()
        }
    }

    /*!
     Simulates a button tap for the given index
     Makes testing a breeze
     - parameter index: The index of the button to tap
     */
    public func tapButtonWithIndex(index: Int) {
        let button = buttons[index]
        button.buttonAction?()
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - View proxy values

extension PopupDialog {

    /// The button alignment of the alert dialog
    public var buttonAlignment: UILayoutConstraintAxis {
        get { return popupContainerView.buttonStackView.axis }
        set {
            popupContainerView.buttonStackView.axis = newValue
            popupContainerView.pv_layoutIfNeededAnimated()
        }
    }

    /// The transition style
    public var transitionStyle: PopupDialogTransitionStyle {
        get { return presentationManager.transitionStyle }
        set { presentationManager.transitionStyle = newValue }
    }
}
