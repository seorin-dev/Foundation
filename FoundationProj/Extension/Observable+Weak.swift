//
//  Observable+Weak.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/22.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension ObservableType {
    /**
     Subscribes an element handler, an error handler, a completion handler and disposed handler to an observable sequence.
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter onDisposed: Action to invoke upon any type of termination of sequence (if the sequence has
     gracefully completed, errored, or if the generation is canceled by disposing subscription).
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    public func subscribeWeakly(onNext: ((Self.Element) -> Void)? = nil, onError: ((Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil) -> RxSwift.Disposable{
        let disposable: Disposable
                
                if let disposed = onDisposed {
                    disposable = Disposables.create(with: disposed)
                }
                else {
                    disposable = Disposables.create()
                }
                
                let callStack = Hooks.recordCallStackOnError ? Hooks.customCaptureSubscriptionCallstack() : []
                
                let observer = AnyObserver<Element> { event in
                    
                    switch event {
                    case .next(let value):
                        
                        onNext?(value)
                    case .error(let error):
                        if let onError = onError {
                            onError(error)
                        }
                        else {
                            Hooks.defaultErrorHandler(callStack, error)
                        }
                        disposable.dispose()
                    case .completed:
                        onCompleted?()
                        disposable.dispose()
                    }
                }
                return Disposables.create(
                    self.asObservable().subscribe(observer),
                    disposable
                )
    }
}
