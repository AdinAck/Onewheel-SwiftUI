//
//  VESC.swift
//  Onewheel-SwiftUI
//
//  Created by Adin Ackerman on 12/2/22.
//

import Foundation
import SwiftUI
import CoreBluetooth

class VESC: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // vesc
    let timeout: UInt32
    @Published var data: DataPackage = DataPackage()
    @Published var fwVersion: FWversionPackage = FWversionPackage()
    
    // user data
    @AppStorage("favorite") var favorite: String = ""
    @AppStorage("top-speed") var topSpeed: Double = 0
    
    // bluetooth
    var centralManager: CBCentralManager!
    @Published var peripheral: CBPeripheral?
    
    private let SERVICE_UUID: CBUUID = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    
    var RX: CharacteristicWrapper = CharacteristicWrapper(id: CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e"))
    var TX: CharacteristicWrapper = CharacteristicWrapper(id: CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e"))
    
    // bluetooth states
    @Published var connected: Bool = false
    @Published var loaded: Bool = false
    @Published var scanning: Bool = true
    
    @Published var discovered: [CBPeripheral] = []
    
    private var newData: [Data] = []
    private var queue = DispatchQueue(label: "buf-queue")
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    init(timeout_ms: UInt32 = 100) {
        self.timeout = timeout_ms
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            if scanning {
                startScanning()
            }
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
    }
    
    func startScanning() {
        print("Scanning")
        withAnimation {
            discovered = []
        }
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral)")
        
        if !discovered.contains(where: { device in device.identifier == peripheral.identifier }) {
            withAnimation {
                discovered.append(peripheral)
            }
        }
        
        if peripheral.identifier.uuidString == favorite {
            self.peripheral = peripheral
            connect()
        }
    }
    
    func connect() {
        centralManager.connect(self.peripheral!)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        
        centralManager.stopScan()
        
        self.peripheral!.delegate = self
        self.peripheral!.discoverServices([SERVICE_UUID])
        
        withAnimation {
            connected = true
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        print("Discovering services...")
        
        for service in services {
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        print("Discovering characteristics for service: \(service)")
        
        for characteristic in characteristics {
            print("Characteristic: \(characteristic)")
            print("R/W: \(characteristic.properties.contains(.read))/\(characteristic.properties.contains(.write))")
            
            switch characteristic.uuid {
            case RX.id:
                RX.characteristic = characteristic
                print("RX")
            case TX.id:
                TX.characteristic = characteristic
                print("TX")
            default:
                print("Discovered extraneous characteristic.")
            }
        }
        
        // discovered expected characteristics
        if RX.characteristic != nil && TX.characteristic != nil {
            peripheral.setNotifyValue(true, for: TX.characteristic)
            
            withAnimation {
                loaded = true
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == TX.characteristic {
            if let data = characteristic.value {
                queue.sync {
                    self.newData.insert(data, at: 0)
                }
                semaphore.signal()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnect()
    }
    
    func disconnect(manual: Bool = false) {
        DispatchQueue.main.async {
            print("Disconnected.")
            
            if manual {
                self.favorite = ""
                self.centralManager.cancelPeripheralConnection(self.peripheral!)
            }
            self.peripheral = nil
            
            withAnimation {
                self.connected = false
                self.loaded = false
            }
            
            self.startScanning()
        }
    }
    
    func getValues(type: CommPacketID) {
        var index: Int = 0
        let payloadSize: Int = 1
        var payload: [UInt8] = [UInt8].init(repeating: 0, count: payloadSize)
        
        payload[index] = type.rawValue
        index += 1
        
        packSendPayload(payload: payload, lenPay: payloadSize)
                
        var message: [UInt8] = [UInt8].init(repeating: 0, count: 256)

        let _ = receiveUartMessage(payloadReceived: &message)
        
        DispatchQueue.main.sync {
            self.processReadPacket(message: message)
            
            // update records
            self.topSpeed = max(self.topSpeed, self.data.speed)
        }
    }
    
    
    
    func packSendPayload(payload: [UInt8], lenPay: Int) {
        let crcPayload: UInt16 = CRC16.encode(buf: payload, len: lenPay)
        
        var count: Int = 0
        var messageSend: [UInt8] = [UInt8].init(repeating: 0, count: 256)
        
        if lenPay <= 256 {
            messageSend[count] = 2
            messageSend[count + 1] = UInt8(lenPay)
            
            count += 2
        } else {
            messageSend[count] = 3
            messageSend[count + 1] = UInt8(lenPay >> 8)
            messageSend[count + 2] = UInt8(lenPay & 0xFF)
            
            count += 3
        }
        
        for i in 0..<lenPay {
            messageSend[i + count] = payload[i]
        }
        
        count += lenPay
        
        messageSend[count] = UInt8(crcPayload >> 8)
        messageSend[count + 1] = UInt8(crcPayload & 0xFF)
        messageSend[count + 2] = 3
        
        count += 3
        
        messageSend = Array(messageSend[0..<count])
        
        let data = messageSend.withUnsafeBufferPointer({ num in
            Data(num)
        })
        
        peripheral?.writeValue(data, for: RX.characteristic, type: .withResponse)
    }
    
    func receiveUartMessage(payloadReceived: inout [UInt8]) -> Int {
        var counter: UInt16 = 0
        var endMessage: UInt16 = 256
        var messageRead: Bool = false
        var messageReceived: [UInt8] = []
        var lenPayload: UInt16 = 0
        
        var buf: [UInt8] = []
        
        while !messageRead {

            let timeout = semaphore.wait(timeout: DispatchTime(uptimeNanoseconds: 1_000_000_000))
            
            guard timeout == .success else { return 0 }
            
            queue.sync { buf.append(contentsOf: newData.popLast()!) }
            
            repeat {
                messageReceived.append(buf[Int(counter)])
                counter += 1
                
                if counter == 2 {
                    switch messageReceived[0] {
                    case 2:
                        endMessage = UInt16(messageReceived[1]) + 5
                        lenPayload = UInt16(messageReceived[1])
                    case 3:
                        print("Message is larger than 256 bytes - not supported")
                    default:
                        print("Invalid start bit.")
                        return 0
                    }
                }
                
                if counter > 255 {
                    return 0
                }
                
                if counter == endMessage && messageReceived[Int(endMessage) - 1] == 3 {
                    messageReceived.append(0)
                    messageRead = true
                    break;
                }
            } while counter < buf.count
        }
        
        let unpacked: Bool = unpackPayload(message: messageReceived, lenMes: Int(endMessage), payload: &payloadReceived)
        
        if unpacked {
            return Int(lenPayload)
        }
        
        return 0
    }
    
    func unpackPayload(message: [UInt8], lenMes: Int, payload: inout [UInt8]) -> Bool {
        var crcMessage: UInt16 = 0
        var crcPayload: UInt16 = 0
        
        crcMessage = UInt16(message[lenMes - 3]) << 8
        crcMessage &= 0xFF00
        crcMessage += UInt16(message[lenMes - 2])
        
        for i in 0..<Int(message[1]) {
            payload[i] = message[i + 2]
        }
        
        crcPayload = CRC16.encode(buf: payload, len: Int(message[1]))
        
        if crcPayload == crcMessage {
            return true
        }
        
        return false
    }
    
    func processReadPacket(message _message: [UInt8]) {
        let packetID: CommPacketID = CommPacketID(rawValue: _message[0])!
        var index: Int = 0
        
        let message = Array(_message[1...])
        
//        print("Processing \(packetID) for packet:")
//        print(message)
        
        switch packetID {
        case .COMM_FW_VERSION:
            fwVersion.major = message[index]
            fwVersion.minor = message[index + 1]
            
            index += 2
            
        case .COMM_GET_VALUES:
            data.tempMosfet       = Buffer.getFloat16(buf: message, scale: 10.0, index: &index)
            data.tempMotor        = Buffer.getFloat16(buf: message, scale: 10.0, index: &index)
            data.avgMotorCurrent  = Buffer.getFloat32(buf: message, scale: 100.0, index: &index)
            data.avgInputCurrent  = Buffer.getFloat32(buf: message, scale: 100.0, index: &index)
            index += 8            // skip id and iq
            data.dutyCycleNow     = Buffer.getFloat16(buf: message, scale: 1000.0, index: &index)
            data.rpm              = Buffer.getFloat32(buf: message, scale: 1.0, index: &index)
            
            if data.current != 0 || data.startingSOC == nil {
                data.inpVoltage   = Buffer.getFloat16(buf: message, scale: 10.0, index: &index)
            } else {
                index += 2
            }
            
            data.ampHours         = Buffer.getFloat32(buf: message, scale: 10000.0, index: &index)
            data.ampHoursCharged  = Buffer.getFloat32(buf: message, scale: 10000.0, index: &index)
            data.wattHours        = Buffer.getFloat32(buf: message, scale: 10000.0, index: &index)
            data.wattHoursCharged = Buffer.getFloat32(buf: message, scale: 10000.0, index: &index)
            data.tachometer       = Buffer.getInt32(buf: message, index: &index)
            data.tachometerAbs    = Buffer.getInt32(buf: message, index: &index)
            data.error            = MCFaultCode(rawValue: message[index])!
            index += 1
            data.pidPos           = Buffer.getFloat32(buf: message, scale: 1000000.0, index: &index)
            data.id               = message[index]
            index += 1
            
        case .COMM_GET_DECODED_BALANCE:
            index += 4            // skip pid_output
            data.pitchAngle       = Buffer.getFloat32(buf: message, scale: 1000000.0, index: &index)
            data.rollAngle        = Buffer.getFloat32(buf: message, scale: 1000000.0, index: &index)
            index += 12           // skip diff_time, motor_current, debug1
            data.opState          = BalanceState(rawValue: Buffer.getUInt16(buf: message, index: &index))!
            data.switchState      = SwitchState(rawValue: Buffer.getUInt16(buf: message, index: &index))!
            data.adc1             = Buffer.getFloat32(buf: message, scale: 1000000.0, index: &index)
            data.adc2             = Buffer.getFloat32(buf: message, scale: 1000000.0, index: &index)
            
        default:
            print("Invalid packet received.")
        }
        
        objectWillChange.send()
    }
}
