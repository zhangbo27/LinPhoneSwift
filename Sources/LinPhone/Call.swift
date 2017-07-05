//
//  Call.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/4/17.
//
//

import CLinPhone

/// LinPhone Call class.
public final class Call {
    
    // MARK: - Properties
    
    @_versioned
    internal let managedPointer: ManagedPointer<UnmanagedPointer>
    
    // MARK: - Initialization
    
    @inline(__always)
    internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
        
        self.managedPointer = managedPointer
    }
    
    // MARK: - Accessors
    
    /// Get the `Linphone.Core` object that has created the specified call.
    public var core: Core {
        
        return getManagedHandle(linphone_call_get_core)!
    }
    
    /// Gets the transferer if this call was started automatically as a result of an incoming transfer request.
    /// The call in which the transfer request was received is returned in this case.
    /// 
    /// - Returns: The transferer call if the specified call was started automatically as a result of
    /// an incoming transfer request or `nil` otherwise.
    public var transferer: Call? {
        
        return getManagedHandle(linphone_call_get_transferer_call)
    }
    
    /// When this call has received a transfer request, returns the new call that was automatically created 
    /// as a result of the transfer.
    public var transferTarget: Call? {
        
        return getManagedHandle(linphone_call_get_transfer_target_call)
    }
    
    /// Returns the call object this call is replacing, if any. 
    ///
    /// Call replacement can occur during call transfers. 
    /// By default, the `Core` automatically terminates the replaced call and accept the new one. 
    /// This property allows the application to know whether a new incoming call is a one that replaces another one.
    public var replaced: Call? {
        
        return getManagedHandle(linphone_call_get_replaced_call)
    }
    
    /// The call's current state.
    public var state: State {
        
        @inline(__always)
        get { return State(linphone_call_get_state(rawPointer)) }
    }
    
    /// Tell whether a call has been asked to autoanswer
    /// 
    /// - Returns: A boolean value telling whether the call has been asked to autoanswer.
    public var askedToAutoanswer: Bool {
        
        @inline(__always)
        get { return linphone_call_asked_to_autoanswer(rawPointer).boolValue }
    }
    
    /// Returns the remote address associated to this call.
    public var remoteAddress: Address? {
        
        return getReferenceConvertible(.externallyRetainedImmutable, linphone_call_get_remote_address)
    }
    
    /// Returns the remote address associated to this call.
    public var remoteAddressString: String? {
        
        @inline(__always)
        get { return getString(linphone_call_get_remote_address_as_string) }
    }
    
    /*
    /// Returns the 'to' address with its headers associated to this call.
    public var toAddress: Address? {
        
        return getReferenceConvertible(.externallyRetained, linphone_call_get_to_address)
    }*/
    
    /// Returns the diversion address associated to this call.
    public var diversionAddress: Address? {
        
        return getReferenceConvertible(.externallyRetainedImmutable, linphone_call_get_diversion_address)
    }
    
    /// Returns call's duration in seconds.
    public var duration: Int {
        
        @inline(__always)
        get { return Int(linphone_call_get_duration(rawPointer)) }
    }
    
    /// Returns direction of the call (incoming or outgoing).
    public var direction: Direction {
        
        @inline(__always)
        get { return Direction(linphone_call_get_dir(rawPointer)) }
    }
    
    //public var log: Call.Log 
    // linphone_call_get_call_log
    
    /// Gets the refer-to uri (if the call was transfered).
    public var referTo: String? {
        
        @inline(__always)
        get { return getString(linphone_call_get_refer_to) }
    }
    
    /// Returns `true` if this calls has received a transfer that has not been executed yet. 
    /// Pending transfers are executed when this call is being paused or closed, locally or by remote endpoint. 
    /// If the call is already paused while receiving the transfer request, the transfer immediately occurs.
    public var hasTransferPending: Bool {
        
        @inline(__always)
        get { return linphone_call_has_transfer_pending(rawPointer).boolValue }
    }
    
    /// Indicates whether camera input should be sent to remote end.
    public var isCameraEnabled: Bool {
        
        @inline(__always)
        get { return linphone_call_camera_enabled(rawPointer).boolValue }
        
        @inline(__always)
        set { linphone_call_enable_camera(rawPointer, bool_t(newValue)) }
    }
    
    /// Returns the reason for a call termination (either error or normal termination)
    public var reason: Reason {
        
        @inline(__always)
        get { return Reason(linphone_call_get_reason(rawPointer)) }
    }
    
    // MARK: - Methods
    
    /// Accept an incoming call.
    ///
    /// Basically the application is notified of incoming calls within the `call state changed` callback,
    /// where it will receive a `.incoming` event with the associated `Linphone.Call` object.
    ///
    /// The application can later accept the call using this method.
    @inline(__always)
    public func accept() -> Bool {
        
        return linphone_call_accept(rawPointer) == .success
    }
    
    /// Pauses the call.
    ///
    /// If a music file has been setup using `Linphone.Core.setPlayFile()`, this file will be played to the remote user.
    /// The only way to resume a paused call is to call `resume()`.
    @inline(__always)
    public func pause() -> Bool {
        
        return linphone_call_pause(rawPointer) == .success
    }
    
    /// Resumes a call.
    ///
    /// The call needs to have been paused previously with `pause()`.
    @inline(__always)
    public func resume() -> Bool {
        
        return linphone_call_resume(rawPointer) == .success
    }
    
    /// Take a photo of currently received video and write it into a jpeg file. 
    /// Note that the snapshot is asynchronous, an application shall not assume 
    /// that the file is created when the method returns.
    @inline(__always)
    public func takeVideoSnapshot(file: String) -> Bool {
        
        return linphone_call_take_video_snapshot(rawPointer, file) == .success
    }
    
    /// Take a photo of currently captured video and write it into a jpeg file. 
    /// Note that the snapshot is asynchronous, an application shall not assume 
    /// that the file is created when the function returns.
    @inline(__always)
    public func takePreviewSnapshot(file: String) -> Bool {
        
        return linphone_call_take_preview_snapshot(rawPointer, file) == .success
    }
}

// MARK: - Supporting Types

public extension Call {
    
    /// represents the different state a call can reach into.
    public enum State: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneCallState
        
        /// Initial call state
        case idle
        
        /// This is a new incoming call
        case incomingReceived
        
        /// An outgoing call is started
        case outgoingInit
        
        /// An outgoing call is in progress
        case outgoingProgress
        
        /// An outgoing call is ringing at remote end
        case outgoingRinging
        
        /// An outgoing call is proposed early media
        case outgoingEarlyMedia
        
        /// Connected, the call is answered
        case connected
        
        /// The media streams are established and running
        case streamsRunning
        
        /// The call is pausing at the initiative of local end
        case pausing
        
        /// The call is paused, remote end has accepted the pause
        case paused
        
        /// The call is being resumed by local end
        case resuming
        
        /// The call is being transfered to another party, resulting in a new outgoing call to follow immediately
        case refered
        
        /// The call encountered an error
        case error
        
        /// The call ended normally
        case end
        
        /// The call is paused by remote end
        case pausedByRemote
        
        /// The call's parameters change is requested by remote end, used for example when video is added by remote
        case updatedByRemote
        
        /// We are proposing early media to an incoming call
        case incomingEarlyMedia
        
        /// A call update has been initiated by us
        case updating
        
        /// The call object is no more retained by the core
        case released
        
        /// The call is updated by remote while not yet answered (early dialog SIP UPDATE received)
        case earlyUpdatedByRemote
        
        /// We are updating the call while not yet answered (early dialog SIP UPDATE sent)
        case earlyUpdating
    }
}

extension Call.State: CustomStringConvertible {
    
    public var description: String {
        
        return String(cString: linphone_call_state_to_string(self.linPhoneType))
    }
}

extension Call {
    
    /// Enum representing the status of a call.
    public enum Status: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneCallStatus
        
        /// The call was sucessful.
        case success
        
        /// The call was aborted.
        case aborted
        
        /// The call was missed (unanswered)
        case missed
        
        /// The call was declined, either locally or by remote end
        case declined
        
        /// The call was aborted before being advertised to the application - for protocol reasons.
        case earlyAborted
    }
}

extension Call {
    
    public enum Direction: UInt32, LinPhoneEnumeration {
        
        public typealias LinPhoneType = LinphoneCallDir
        
        case outgoing
        case incoming
    }
}

// MARK: - ManagedHandle

extension Call: ManagedHandle {
    
    typealias RawPointer = UnmanagedPointer.RawPointer
    
    struct UnmanagedPointer: LinPhone.UnmanagedPointer {
        
        let rawPointer: OpaquePointer
        
        @inline(__always)
        init(_ rawPointer: UnmanagedPointer.RawPointer) {
            self.rawPointer = rawPointer
        }
        
        @inline(__always)
        func retain() {
            linphone_call_ref(rawPointer)
        }
        
        @inline(__always)
        func release() {
            linphone_call_unref(rawPointer)
        }
    }
}

extension Call: UserDataHandle {
    
    static var userDataGetFunction: (OpaquePointer?) -> UnsafeMutableRawPointer? {
        return linphone_call_get_user_data
    }
    
    static var userDataSetFunction: (_ UnmanagedPointer: OpaquePointer?, _ userdata: UnsafeMutableRawPointer?) -> () {
        return linphone_call_set_user_data
    }
}
