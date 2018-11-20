//
//  Copyright © 2018 Microsoft Corporation. All rights reserved.
//

import Foundation

// MARK: MSDateTimePickerViewMode

enum MSDateTimePickerViewMode {
    case date(startYear: Int, endYear: Int)
    case dateTime   /// Date hour/minute am/pm
    case dayOfMonth /// Week of month / Day of week

    static let defaultStartYear: Int = MSCalendarConfiguration.default.referenceStartDate.year
    static let defaultEndYear: Int = MSCalendarConfiguration.default.referenceEndDate.year
}

// MARK: - MSDateTimePickerViewDelegate

protocol MSDateTimePickerViewDelegate: class {
    func dateTimePickerView(_ dateTimePickerView: MSDateTimePickerView, accessibilityValueOverwriteForDate date: Date, originalValue: String?) -> String?
}

// MARK: - MSDateTimePickerView

/*
 * Custom Date picker view
 *
 * Public
 * - init(type: MSDateTimePickerViewMode)
 * - property date: Date
 * - setDate(date: Date, animated: Bool)
 *
 * To use:
 *  - Initialize with the types you want (see MSDateTimePickerViewMode)
 *  - Set the date you want to show first
 *  - Listen to UIControlEventChanged to get notified of changes. It is only fired when the change is initiated by the user
 *  - Query the date property to retrieve a Date
 */
class MSDateTimePickerView: UIControl {
    let mode: MSDateTimePickerViewMode
    private(set) var date = Date()
    private(set) var dayOfMonth = MSDayOfMonth()

    weak var delegate: MSDateTimePickerViewDelegate?

    private let componentTypes: [MSDateTimePickerViewComponentType]!
    private let componentsByType: [MSDateTimePickerViewComponentType: MSDateTimePickerViewComponent]!

    private let selectionTopSeparator = MSSeparator()
    private let selectionBottomSeparator = MSSeparator()

    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 0).cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        return gradientLayer
    }()

    private var amPMValue: MSDateTimePickerViewAMPM?

    init(mode: MSDateTimePickerViewMode) {
        self.mode = mode

        componentTypes = MSDateTimePickerViewLayout.componentTypes(fromDatePickerMode: mode)
        componentsByType = MSDateTimePickerViewLayout.componentsByType(fromTypes: componentTypes, mode: mode)

        super.init(frame: .zero)

        for component in componentsByType.values {
            component.delegate = self
            addSubview(component.view)
        }

        layer.addSublayer(gradientLayer)
        addSubview(selectionTopSeparator)
        addSubview(selectionBottomSeparator)

        backgroundColor = MSColors.background

        setDate(date, animated: false)
        setDayOfMonth(dayOfMonth, animated: false)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Set the date displayed on the picker. This does not trigger UIControlEventValueChanged
    ///
    /// - Parameters:
    ///   - date: The new date to be displayed/selected in the picker
    ///   - animated: Whether to animate the change to the new date
    func setDate(_ date: Date, animated: Bool) {
        let newDate = date.rounded(toCalendarUnits: [.year, .month, .day, .hour, .minute])
        guard newDate != self.date else {
            return
        }

        self.date = newDate

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let amPM: MSDateTimePickerViewAMPM = dateComponents.hour! > 11 ? .pm : .am

        componentsByType[.date]?.select(item: calendar.startOfDay(for: date), animated: animated, userInitiated: false)
        componentsByType[.month]?.select(item: dateComponents.month, animated: animated, userInitiated: false)
        componentsByType[.day]?.select(item: dateComponents.day, animated: animated, userInitiated: false)
        componentsByType[.year]?.select(item: dateComponents.year, animated: animated, userInitiated: false)
        componentsByType[.timeAMPM]?.select(item: amPM, animated: animated, userInitiated: false)
        componentsByType[.timeHour]?.select(item: dateComponents.hour, animated: animated, userInitiated: false)
        componentsByType[.timeMinute]?.select(item: dateComponents.minute, animated: animated, userInitiated: false)

        updateAMPM(forHour: dateComponents.hour!)
    }

    func setDayOfMonth(_ dayOfMonth: MSDayOfMonth, animated: Bool) {
        self.dayOfMonth = dayOfMonth

        componentsByType[.weekOfMonth]?.select(item: dayOfMonth.weekOfMonth, animated: animated, userInitiated: false)
        componentsByType[.dayOfWeek]?.select(item: dayOfMonth.dayOfWeek, animated: animated, userInitiated: false)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return MSDateTimePickerViewLayout.sizeThatFits(size, mode: mode)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Compute ratio to ideal width
        let idealWidth = sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
        let widthRatio = (width - 2 * MSDateTimePickerViewLayout.horizontalPadding) / (idealWidth - 2 * MSDateTimePickerViewLayout.horizontalPadding)

        // Compute components width based on the ratio of this width to ideal width
        var componentWidths: [CGFloat] = componentTypes.map {
            let componentIdealWidth = MSDateTimePickerViewLayout.componentWidths[$0] ?? 0
            return floor(componentIdealWidth * widthRatio)
        }

        // Layout components
        var x: CGFloat = MSDateTimePickerViewLayout.horizontalPadding
        for (index, type) in componentTypes.enumerated() {
            guard let component = componentsByType[type] else {
                continue
            }
            let viewWidth = componentWidths[index]
            component.view.frame = CGRect(x: x, y: 0, width: viewWidth, height: height)

            // Make sure views are all setup before setting date at the bottom of the function
            component.view.layoutIfNeeded()
            x += viewWidth
        }

        let lineOffset = round((height - MSDateTimePickerViewComponentCell.idealHeight - 2 * selectionTopSeparator.height) / 2)

        selectionTopSeparator.frame = CGRect(x: 0, y: lineOffset, width: width, height: selectionTopSeparator.height)

        selectionBottomSeparator.frame = CGRect(
            x: 0,
            y: height - lineOffset - selectionBottomSeparator.height,
            width: width,
            height: selectionBottomSeparator.height
        )

        gradientLayer.locations = [0, NSNumber(value: Float(lineOffset / height)), NSNumber(value: Float((height - lineOffset) / height)), 1]
        gradientLayer.frame = bounds

        setDate(date, animated: false)
        setDayOfMonth(dayOfMonth, animated: false)
    }

    private func type(of component: MSDateTimePickerViewComponent) -> MSDateTimePickerViewComponentType? {
        return componentsByType.first(where: { $1 == component })?.key
    }

    private func updateDate() {
        let calendar = Calendar.sharedCalendarWithTimeZone(nil)
        var dateComponents = DateComponents()

        dateComponents.hour = componentsByType[.timeHour]?.selectedItem as? Int
        dateComponents.minute = componentsByType[.timeMinute]?.selectedItem as? Int

        if let date = componentsByType[.date]?.selectedItem as? Date {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.year = components.year
            dateComponents.month = components.month
            dateComponents.day = components.day
        }

        if let year = componentsByType[.year]?.selectedItem as? Int {
            dateComponents.year = year
        }

        if let month = componentsByType[.month]?.selectedItem as? Int {
            dateComponents.month = month
        }

        if let dayComponent = componentsByType[.day], let day = dayComponent.selectedItem as? Int {
            // In case the day is greater than the number of days for a given month, create a testDate to find the max. We'll use the max day for that month if current day is greater.
            // Ex: Feb 29, 2016 -> Feb 29, 2017 is invalid, so we would instead use Feb 28, 2017
            dateComponents.day = 1
            if let testDate = calendar.date(from: dateComponents) {
                let newDay = min(calendar.range(of: .day, in: .month, for: testDate)?.count ?? 28, day)
                dateComponents.day = newDay

                // Update date picker in case the number of days for that month has changed
                if let dataSource = dayComponent.dataSource as? MSDateTimePickerViewDataSourceWithDate {
                    dataSource.date = testDate
                    if let indexPath = dataSource.indexPath(forItem: day) {
                        dayComponent.reloadData()
                        dayComponent.view.layoutIfNeeded()
                        dayComponent.select(indexPath: indexPath, animated: false, userInitiated: false)
                    }
                }
            } else {
                dateComponents.day = day
            }
        }

        if let amPM = componentsByType[.timeAMPM]?.selectedItem as? MSDateTimePickerViewAMPM {
            var hour = dateComponents.hour
            switch amPM {
            case .am:
                hour = hour == 12 ? 0 : hour
            case .pm:
                hour = hour! == 12 ? hour : hour! + 12
            }
            dateComponents.hour = hour
        }

        date = calendar.date(from: dateComponents) ?? date

        let weekOfMonth = componentsByType[.weekOfMonth]?.selectedItem as? MSWeekOfMonth ?? dayOfMonth.weekOfMonth
        let dayOfWeek = componentsByType[.dayOfWeek]?.selectedItem as? MSDayOfWeek ?? dayOfMonth.dayOfWeek
        dayOfMonth = MSDayOfMonth(weekOfMonth: weekOfMonth, dayOfWeek: dayOfWeek)

        sendActions(for: .valueChanged)
    }

    private func updateAMPM(forHour hour: Int) {
        // When we scroll through the hours in 12 hour format. Each time we go to a next cycle, we switch to Am/Pm
        // This makes sure we switch to the right one and we do not switch if the user changed Am/Pm themselve

        guard let component = componentsByType[.timeAMPM], let selectedIndexPath = component.selectedIndexPath else {
            amPMValue = nil
            return
        }

        guard let amPMValue = component.dataSource.item(forRowAtIndex: selectedIndexPath.row) as? MSDateTimePickerViewAMPM else {
            assertionFailure("updateAMPM > amPM value not found")
            return
        }

        let moduloIsEven = ((hour - 1) / 12) % 2 == 0
        self.amPMValue = moduloIsEven ? amPMValue : (amPMValue == .am ? .pm : .am)
    }
}

// MARK: - MSDateTimePickerView: MSDateTimePickerViewComponentDelegate

extension MSDateTimePickerView: MSDateTimePickerViewComponentDelegate {
    func dateTimePickerComponentDidScroll(_ component: MSDateTimePickerViewComponent, userInitiated: Bool) {
        guard let type = type(of: component) else {
            assertionFailure("dateTimePickerComponent > component not found")
            return
        }

        // Scrolling through hours in 12 hours format
        guard type == .timeHour, userInitiated, let indexPath = component.tableView.middleIndexPath, componentTypes.contains(.timeAMPM) else {
            return
        }
        guard let amPMComponent = componentsByType[.timeAMPM], let amPMValue = amPMValue else {
            assertionFailure("dateTimePickerComponent > amPM value not found")
            return
        }

        // Switch between am and pm every cycle
        let moduloIsEven = (indexPath.row / 12) % 2 == 0
        let newValue = moduloIsEven ? amPMValue : (amPMValue == .am ? .pm : .am)

        amPMComponent.select(item: newValue, animated: true, userInitiated: false)
    }

    func dateTimePickerComponent(_ component: MSDateTimePickerViewComponent, didSelectItemAtIndexPath indexPath: IndexPath, userInitiated: Bool) {
        if userInitiated {
            if type(of: component) == .timeAMPM, let hour = componentsByType[.timeHour]?.selectedItem as? Int {
                updateAMPM(forHour: hour)
            }
            updateDate()
        }
    }

    /**
     * Getting accessibility value on demand is tricky. Components don't know the full date. They only know their
     * components. And the row has not been selected yet when the accessibility value is asked for. Therefore, the
     * components send the component info that Cocoa asks the accessibility value for. Then the Picker computes
     * the date and sends back the availability accessibility value for it
     *
     * In summary, this can be used to override the accessibility value for the entire view based on the date rather than individual components.
     */
    func dateTimePickerComponent(_ component: MSDateTimePickerViewComponent, accessibilityValueForDateComponents dateComponents: DateComponents?, originalValue: String?) -> String? {
        guard let delegate = delegate else {
            return originalValue
        }

        // Create date from received components.
        // Accessibility value is asked by Cocoa before the row is selected. So we need another way of knowing the current date
        // When is about to change and Cocoa asks the accessibility value for it, we get the date components of this row to compute the new date
        let calendar = Calendar.current

        var currentDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        if let dateComponents = dateComponents {
            currentDateComponents.year = dateComponents.year ?? currentDateComponents.year
            currentDateComponents.month = dateComponents.month ?? currentDateComponents.month
            currentDateComponents.day = dateComponents.day ?? currentDateComponents.day
            currentDateComponents.hour = dateComponents.hour ?? currentDateComponents.hour
            currentDateComponents.minute = dateComponents.minute ?? currentDateComponents.minute
        }

        // Hours and AM/PM are different components. Therefore they don't know each other and can't compute the 24Hour time by themselves.
        // We compute this here.
        if var amPM = componentsByType[.timeAMPM]?.selectedItem as? MSDateTimePickerViewAMPM {
            guard var hour = currentDateComponents.hour else {
                assertionFailure("Invalid date")
                return nil
            }

            if let era = dateComponents?.era {
                // Hack for AM/PM. The AM/PM row is stored in "era" of date components
                amPM = era == 0 ? .am : .pm
            }

            // Offset the hour so that it is the correct 24Hour
            switch amPM {
            case .am:
                hour = hour >= 12 ? hour - 12 : hour
            case .pm:
                hour = hour >= 12 ? hour : hour + 12
            }
            currentDateComponents.hour = hour
        }

        guard let date = calendar.date(from: currentDateComponents) else {
            assertionFailure("Invalid date")
            return nil
        }

        return delegate.dateTimePickerView(self, accessibilityValueOverwriteForDate: date, originalValue: originalValue)
    }
}
