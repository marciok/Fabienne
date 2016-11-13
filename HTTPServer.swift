//
//  WebServer.swift
//  Fabienne
//
//  Created by Marcio Klepacz on 11/8/16.
//  Copyright © 2016 Marcio Klepacz. All rights reserved.
//

import Foundation

typealias SocketDescriptor = Int32

enum SocketError: Error {
    case failed(String)
}

func errnoDescription() -> String {
   return String(cString: UnsafePointer(strerror(errno)))
}

struct Socket {
    let descriptor: SocketDescriptor
    
    init() {
        descriptor = Darwin.socket(AF_INET, SOCK_STREAM, 0)
    }
    
    init(descriptor: SocketDescriptor) {
        self.descriptor = descriptor
    }
    
    static let CarriageReturn = UInt8(13)
    static let NewLine = UInt8(10)
    
    func bindAndListen(port: in_port_t = 8080) throws {
        
        if descriptor == -1 {
            throw SocketError.failed(errnoDescription())
        }
        
        var address = sockaddr_in(
            sin_len: UInt8(MemoryLayout<sockaddr_in>.stride),
            sin_family: UInt8(AF_INET),
            sin_port: port.bigEndian,
            sin_addr: in_addr(s_addr: in_addr_t(0)),
            sin_zero:(0, 0, 0, 0, 0, 0, 0, 0))
        
        var bindResult: Int32 = -1
        bindResult = withUnsafePointer(to: &address) {
            bind(descriptor, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in>.size))
        }
        
        if bindResult == -1 {
            throw SocketError.failed(errnoDescription())
        }
        
        if listen(descriptor, SOMAXCONN) == -1 {
            throw SocketError.failed(errnoDescription())
        }
    }
    
    func acceptClient() throws -> Socket {
        var addr = sockaddr()
        var len: socklen_t = 0
        let clientSocket = accept(descriptor, &addr, &len)
        if clientSocket == -1 {
            throw SocketError.failed(errnoDescription())
        }
        
        return Socket(descriptor: clientSocket)
    }
    
    func readLine() throws -> String {
        var characters = ""
        var n: UInt8 = 0
        repeat {
            n = try read()
            if n > Socket.CarriageReturn {
                characters.append(Character(UnicodeScalar(n)))
            }
        } while n != Socket.NewLine
        
        return characters
    }
    
    func read() throws -> UInt8 {
        var buffer = [UInt8](repeatElement(0, count: 1))
        let next = recv(descriptor, &buffer, Int(buffer.count), 0)
        if next <= 0 {
            throw SocketError.failed(errnoDescription())
        }
        
        return buffer[0]
    }
    
    func write(message: String) throws -> String {
        let data = ArraySlice(message.utf8)
        
        try data.withUnsafeBufferPointer {
            var sent = 0
            let length = data.count
            while sent < length {
                let s = Darwin.write(descriptor, $0.baseAddress! + sent, Int(length - sent))
                if s <= 0 {
                    throw SocketError.failed("could send")
                }
                sent += s
            }
        }
        
        return message
    }
    
    func writeOK() throws -> String {
        return try write(message: "HTTP/1.1 200 OK\r\n")
    }
    
    func write404() throws -> String {
        return try write(message: "HTTP/1.1 404 Not Found\r\n")
    }
    
    func close() throws {
        guard Darwin.close(descriptor) == 0 else {
            throw SocketError.failed(errnoDescription())
        }
    }
    
}

struct HTTPServer {
    let socket: Socket
    var handlers: [String : (Void) -> Int]
    
    func start(port: in_port_t = 8080) throws {
        try socket.bindAndListen()
        
        while let client = try? socket.acceptClient() {
            let response = try client.readLine()
            let statusLineTokens = response.characters.split { $0 == " " }.map(String.init)
            
            guard let handler = handlers[statusLineTokens[1]] else {
                _ = try client.write404()
                try client.close()
                
                continue
            }
            
            let content = String(handler())
            
            let data = [UInt8](content.utf8)
            
            print("Received: \(response)")
            
            print(try client.writeOK())
            print(try client.write(message: "Content-Length: \(data.count)\r\n"))
            print(try client.write(message: "\r\n"))
            print(try client.write(message: content))
            
            try client.close()
        }
    }
}
