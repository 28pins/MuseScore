//
//  TouchBarController.swift
//  MuseScore
//
//  Created by Sam Clark on 5/18/26.
//

import Foundation
import AppKit

@MainActor @objc class TouchBarController: NSObject, NSTouchBarDelegate {
	var touchBar: NSTouchBar?
	var touchBarItems: [String: NSTouchBarItem] = [:]
	var touchBarItemIdentifiers: [String] {
		return Array(touchBarItems.keys)
	}
	weak var delegate: TouchBarDelegate?
	var orderedIdentifiers: [String] = []

	@objc init(delegate: TouchBarDelegate?) {
		super.init()
		touchBarItems = [:]
		touchBar = NSTouchBar()
		touchBar?.delegate = self
		touchBar?.defaultItemIdentifiers = []
		self.delegate = delegate
	}

	@objc func showForWindow(_ window: NSWindow?) {
		window?.touchBar = self.touchBar
	}

	@objc func addButton(actionCode: String, title: String, imageData: Data?) {
		let itemIdentifier = NSTouchBarItem.Identifier(actionCode)
		let button = NSButton(title: title, target: self, action: #selector(self.buttonPressed(_:)))
		button.identifier = .init(actionCode)
		if let imageData = imageData, let image = NSImage(data: imageData) {
			image.isTemplate = true
			button.image = image
		}
		let customItem = NSCustomTouchBarItem(identifier: itemIdentifier)
		customItem.view = button
		self.touchBarItems[actionCode] = customItem
		if !self.orderedIdentifiers.contains(actionCode) { self.orderedIdentifiers.append(actionCode) }
		self.touchBar?.defaultItemIdentifiers = self.orderedIdentifiers.map { NSTouchBarItem.Identifier($0) }
	}

	@objc func removeButton(actionCode: String) {
		self.touchBarItems.removeValue(forKey: actionCode)
		self.touchBar?.defaultItemIdentifiers.removeAll { $0.rawValue == actionCode }
	}

	@objc func setEnabled(_ actionCode: String, enabled: Bool) {
		if let item = self.touchBarItems[actionCode] {
			(item.view as? NSControl)?.isEnabled = enabled
		}
	}

	@objc func setChecked(_ actionCode: String, checked: Bool) {
		if let item = self.touchBarItems[actionCode] {
			(item.view as? NSButton)?.state = checked ? .on : .off
		}
	}

	@objc func buttonPressed(_ sender: NSButton) {
		guard let actionCode = sender.identifier?.rawValue else { return }
		delegate?.touchBarButtonPressed(actionCode: actionCode)
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		return touchBarItems[identifier.rawValue]
	}
}

@objc protocol TouchBarDelegate: AnyObject {
	func touchBarButtonPressed(actionCode: String)
}
