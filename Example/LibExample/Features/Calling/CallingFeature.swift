//
//  CallingFeature.swift
//  LibExample
//
//  Created by Manuel on 08/10/2019.
//  Copyright © 2019 Harold. All rights reserved.
//

final class CallingFeature: Feature {
    
    required init(with rootMessageHandler: MessageHandling) {
        self.rootMessageHandler = rootMessageHandler
    }
    
    private weak var rootMessageHandler:MessageHandling?
    
    // useCases
    private lazy var startCall  = StartCall() { [weak self] response in self?.handle(response: response) }
    private lazy var endCall    = EndCall()   { [weak self] response in self?.handle(response: response) }
    private lazy var createCall = CreateCall(){ [weak self] response in self?.handle(response: response) }

    func handle(feature: Message.Feature) {
        if case .calling(.useCase(let useCase)) = feature {
            handle(useCase: useCase)
        }
    }
    
    private func handle(useCase: Message.Feature.Calling.UseCase) {
        if case .call(.action(.start(let handle))) = useCase { createCall.handle(request: .createCall(handle)) }
        if case .call(.action(.stop (let call)))   = useCase {    endCall.handle(request:       .stop  (call)) }
    }
    
    private func handle(response: CreateCall.Response) {
        switch response {
        case .callCreated(let call): startCall.handle(request: .startCall(call))
        }
    }
    
    private func handle(response: StartCall.Response) {
        switch response {
        case        .dialing(let call): rootMessageHandler?.handle(msg: .feature(.calling(.useCase(.call(.action(     .dialing(call)))))))
        case   .callDidStart(let call): rootMessageHandler?.handle(msg: .feature(.calling(.useCase(.call(.action(.callDidStart(call)))))))
        case .failedStarting(let call): rootMessageHandler?.handle(msg: .feature(.calling(.useCase(.call(.action(  .callFailed(call)))))))
        }
    }

    private func handle(response: EndCall.Response) {
        switch response {
        case .callDidStop(let call):
            rootMessageHandler?.handle(msg: .feature(.calling(.useCase(.call(.action(.callDidStop(call)))))))
        }
    }
}
