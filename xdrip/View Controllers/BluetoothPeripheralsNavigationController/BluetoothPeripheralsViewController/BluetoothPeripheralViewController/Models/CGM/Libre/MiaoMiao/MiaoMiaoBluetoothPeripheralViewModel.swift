import UIKit

class MiaoMiaoBluetoothPeripheralViewModel {
    
    // MARK: - private properties
    
    /// settings specific for MiaoMiao
    private enum Settings:Int, CaseIterable {
        
        /// battery level
        case batteryLevel = 0
        
        /// firmware version
        case firmWare = 1
        
        /// hardware version
        case hardWare = 2
        
        /// Sensor serial number
        case sensorSerialNumber = 3
        
    }
    
    /// MiaoMiao settings willb be in section 0 + numberOfGeneralSections
    private let sectionNumberForMiaoMiaoSpecificSettings = 0
    
    /// reference to bluetoothPeripheralManager
    private weak var bluetoothPeripheralManager: BluetoothPeripheralManaging?
    
    /// reference to the tableView
    private weak var tableView: UITableView?
    
    /// reference to BluetoothPeripheralViewController that will own this WatlaaMasterBluetoothPeripheralViewModel - needed to present stuff etc
    private weak var bluetoothPeripheralViewController: BluetoothPeripheralViewController?
    
    /// temporary reference to bluetoothPerpipheral, will be set in configure function.
    private var bluetoothPeripheral: BluetoothPeripheral?
    
    /// it's the bluetoothPeripheral as M5Stack
    private var MiaoMiao: MiaoMiao? {
        get {
            return bluetoothPeripheral as? MiaoMiao
        }
    }
    
    // MARK: - deinit
    
    deinit {

        // when closing the viewModel, and if there's still a bluetoothTransmitter existing, then reset the specific delegate to BluetoothPeripheralManager
        
        guard let bluetoothPeripheralManager = bluetoothPeripheralManager else {return}
        
        guard let MiaoMiao = MiaoMiao else {return}
        
        guard let blueToothTransmitter = bluetoothPeripheralManager.getBluetoothTransmitter(for: MiaoMiao, createANewOneIfNecesssary: false) else {return}
        
        guard let cGMMiaoMiaoBluetoothTransmitter = blueToothTransmitter as? CGMMiaoMiaoTransmitter else {return}
        
        cGMMiaoMiaoBluetoothTransmitter.cGMMiaoMiaoTransmitterDelegate = bluetoothPeripheralManager as! BluetoothPeripheralManager

    }
    
}

// MARK: - conform to BluetoothPeripheralViewModel

extension MiaoMiaoBluetoothPeripheralViewModel: BluetoothPeripheralViewModel {

    func canWebOOP() -> Bool {
        return CGMTransmitterType.miaomiao.canWebOOP()
    }
    
    func configure(bluetoothPeripheral: BluetoothPeripheral?, bluetoothPeripheralManager: BluetoothPeripheralManaging, tableView: UITableView, bluetoothPeripheralViewController: BluetoothPeripheralViewController) {
        
        self.bluetoothPeripheralManager = bluetoothPeripheralManager
        
        self.tableView = tableView
        
        self.bluetoothPeripheralViewController = bluetoothPeripheralViewController
        
        self.bluetoothPeripheral = bluetoothPeripheral
        
        if let bluetoothPeripheral = bluetoothPeripheral {
            
            if let miaoMiao = bluetoothPeripheral as? MiaoMiao {
                
                if let blueToothTransmitter = bluetoothPeripheralManager.getBluetoothTransmitter(for: miaoMiao, createANewOneIfNecesssary: false), let cGMMiaoMiaoTransmitter = blueToothTransmitter as? CGMMiaoMiaoTransmitter {
                    
                    // set CGMMiaoMiaoTransmitter delegate to self.
                    cGMMiaoMiaoTransmitter.cGMMiaoMiaoTransmitterDelegate = self
                    
                }
                
            } else {
                fatalError("in MiaoMiaoBluetoothPeripheralViewModel, configure. bluetoothPeripheral is not MiaoMiao")
            }
        }

    }
    
    func screenTitle() -> String {
        return BluetoothPeripheralType.MiaoMiaoType.rawValue
    }
    
    func sectionTitle(forSection section: Int) -> String {
        return BluetoothPeripheralType.MiaoMiaoType.rawValue
    }
    
    func update(cell: UITableViewCell, forRow rawValue: Int, forSection section: Int, for bluetoothPeripheral: BluetoothPeripheral) {
        
        // verify that bluetoothPeripheral is a MiaoMiao
        guard let MiaoMiao = bluetoothPeripheral as? MiaoMiao else {
            fatalError("MiaoMiaoBluetoothPeripheralViewModel update, bluetoothPeripheral is not MiaoMiao")
        }
        
        // default value for accessoryView is nil
        cell.accessoryView = nil
        
        guard let setting = Settings(rawValue: rawValue) else { fatalError("MiaoMiaoBluetoothPeripheralViewModel update, unexpected setting") }
        
        switch setting {
            
        case .batteryLevel:
            
            cell.textLabel?.text = Texts_BluetoothPeripheralsView.batteryLevel
            if MiaoMiao.batteryLevel > 0 {
                cell.detailTextLabel?.text = MiaoMiao.batteryLevel.description + " %"
            } else {
                cell.detailTextLabel?.text = ""
            }
            cell.accessoryType = .none
            
        case .firmWare:
            
            cell.textLabel?.text = Texts_Common.firmware
            cell.detailTextLabel?.text = MiaoMiao.firmware
            cell.accessoryType = .disclosureIndicator
            
        case .hardWare:
            
            cell.textLabel?.text = Texts_Common.hardware
            cell.detailTextLabel?.text = MiaoMiao.hardware
            cell.accessoryType = .disclosureIndicator
            
        case .sensorSerialNumber:
            
            cell.textLabel?.text = Texts_BluetoothPeripheralView.SensorSerialNumber
            cell.detailTextLabel?.text = MiaoMiao.blePeripheral.sensorSerialNumber
            cell.accessoryType = .disclosureIndicator
            
        }

    }
    
    func userDidSelectRow(withSettingRawValue rawValue: Int, forSection section: Int, for bluetoothPeripheral: BluetoothPeripheral, bluetoothPeripheralManager: BluetoothPeripheralManaging) -> SettingsSelectedRowAction {
        
        // verify that bluetoothPeripheral is a MiaoMiao
        guard let MiaoMiao = bluetoothPeripheral as? MiaoMiao else {
            fatalError("MiaoMiaoBluetoothPeripheralViewModel userDidSelectRow, bluetoothPeripheral is not MiaoMiao")
        }
        
        guard let setting = Settings(rawValue: rawValue) else { fatalError("MiaoMiaoBluetoothPeripheralViewModel userDidSelectRow, unexpected setting") }
        
        switch setting {
            
        case .batteryLevel:
            return .nothing
            
        case .firmWare:
            
            // firmware text could be longer than screen width, clicking the row allos to see it in pop up with more text place
            if let firmware = MiaoMiao.firmware {
                return .showInfoText(title: Texts_HomeView.info, message: Texts_Common.firmware + " : " + firmware)
            }

        case .hardWare:

            // hardware text could be longer than screen width, clicking the row allows to see it in pop up with more text place
            if let hardware = MiaoMiao.hardware {
                return .showInfoText(title: Texts_HomeView.info, message: Texts_Common.hardware + " : " + hardware)
            }
            
        case .sensorSerialNumber:
            
            // serial text could be longer than screen width, clicking the row allows to see it in a pop up with more text place
            if let serialNumber = MiaoMiao.blePeripheral.sensorSerialNumber {
                return .showInfoText(title: Texts_HomeView.info, message: Texts_BluetoothPeripheralView.SensorSerialNumber + " : " + serialNumber)
            }
            
        }
        
        return .nothing

    }
    
    func numberOfSettings(inSection section: Int) -> Int {
        return Settings.allCases.count
    }
    
    func numberOfSections() -> Int {
        // for the moment only one specific section for DexcomG5
        return 1
    }
    
}

// MARK: - conform to CGMMiaoMiaoTransmitterDelegate

extension MiaoMiaoBluetoothPeripheralViewModel: CGMMiaoMiaoTransmitterDelegate {
    
    func received(batteryLevel: Int, from cGMMiaoMiaoTransmitter: CGMMiaoMiaoTransmitter) {
        
        // inform also bluetoothPeripheralManager
        (bluetoothPeripheralManager as? CGMMiaoMiaoTransmitterDelegate)?.received(batteryLevel: batteryLevel, from: cGMMiaoMiaoTransmitter)
        
        // here's the trigger to update the table
        reloadRow(row: Settings.batteryLevel.rawValue)

    }
    
    func received(serialNumber: String, from cGMMiaoMiaoTransmitter: CGMMiaoMiaoTransmitter) {
        
        // inform also bluetoothPeripheralManager
        (bluetoothPeripheralManager as? CGMMiaoMiaoTransmitterDelegate)?.received(serialNumber: serialNumber, from: cGMMiaoMiaoTransmitter)
     
        // here's the trigger to update the table
        reloadRow(row: Settings.sensorSerialNumber.rawValue)

    }
    
    func received(firmware: String, from cGMMiaoMiaoTransmitter: CGMMiaoMiaoTransmitter) {
        
        // inform also bluetoothPeripheralManager
        (bluetoothPeripheralManager as? CGMMiaoMiaoTransmitterDelegate)?.received(firmware: firmware, from: cGMMiaoMiaoTransmitter)
        
        // here's the trigger to update the table
        reloadRow(row: Settings.firmWare.rawValue)
        
    }
    
    func received(hardware: String, from cGMMiaoMiaoTransmitter: CGMMiaoMiaoTransmitter) {
        
        // inform also bluetoothPeripheralManager
        (bluetoothPeripheralManager as? CGMMiaoMiaoTransmitterDelegate)?.received(hardware: hardware, from: cGMMiaoMiaoTransmitter)
        
        // here's the trigger to update the table
        reloadRow(row: Settings.hardWare.rawValue)
        
    }
    
    private func reloadRow(row: Int) {
        
        if let bluetoothPeripheralViewController = bluetoothPeripheralViewController {
            
            tableView?.reloadRows(at: [IndexPath(row: row, section: bluetoothPeripheralViewController.numberOfGeneralSections() + sectionNumberForMiaoMiaoSpecificSettings)], with: .none)
        
        }
    }
    
}
