//
//  IAPManager.swift
//  CandyWithMVVMC
//
//  Created by William on 2021/1/26.
//  Copyright © 2021 William. All rights reserved.
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    
    // MARK: - Custom Types
    
    enum IAPManagerError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }

    // MARK: - Properties
    
    static let shared = IAPManager()
    
    var onReceiveProductsHandler: ((Swift.Result<[SKProduct], IAPManagerError>) -> Void)?
    
    var onBuyProductHandler: ((Swift.Result<Bool, Error>) -> Void)?
    
    var totalRestoredPurchases = 0
 
    // MARK: - Init
    
    private override init() {
        super.init()
    }
    
    // MARK: - General Methods
    
    fileprivate func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func fetchAutoSubscriptionProducts() -> [String]? {
        guard let url = Bundle.main.url(forResource: "IAP_AutoSubscriptions", withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getPriceFormatted(for product: SKProduct, amount:Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price.multiplying(by: NSDecimalNumber(value: amount)))
    }
    
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }


    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    
    // MARK: - Get IAP Products
    
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Swift.Result<[SKProduct], IAPManagerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler

        // Get the product identifiers.
        guard let productIDs = getProductIDs() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }

        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))

        // Set self as the its delegate.
        request.delegate = self

        // Make the request.
        request.start()
    }
    
    func getAutoSubscriptionProducts(withHandler productsReceiveHandler: @escaping (_ result: Swift.Result<[SKProduct], IAPManagerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler

        // Get the product identifiers.
        //let identifiers: Set<String> = ["com.app.premium.monthly","com.app.premium.annual"]
        guard let productIDs = fetchAutoSubscriptionProducts() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }

        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))

        // Set self as the its delegate.
        request.delegate = self

        // Make the request.
        request.start()
    }
    
    
    
    // MARK: - Purchase Products
    
    func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Swift.Result<Bool, Error>) -> Void)) {
        
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)

        // Keep the completion handler.
        onBuyProductHandler = handler
    }
    
    func buyWithMulitAmount(product: SKProduct, amount: Int , withHandler handler: @escaping ((_ result: Swift.Result<Bool, Error>) -> Void)) {
        
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        
        let payment = SKMutablePayment(product: product)
        
        guard let dictionary = Bundle.main.infoDictionary else { return }
        if let name: String = dictionary["CFBundleDisplayName"] as? String {
            payment.applicationUsername = name
        }
        payment.quantity = amount
        payment.simulatesAskToBuyInSandbox = true
        //payment.paymentDiscount = SKPaymentDiscount(identifier: "", keyIdentifier: "", nonce: UUID(), signature: "", timestamp: NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000)))
        SKPaymentQueue.default().add(payment)

        // Keep the completion handler.
        onBuyProductHandler = handler
    }
    
    func buyAutoSubscriptionsProudcts(product: SKProduct , withHandler handler: @escaping ((_ result: Swift.Result<Bool, Error>) -> Void)) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        // Keep the completion handler.
        onBuyProductHandler = handler
    }
    
    
    func restorePurchases(withHandler handler: @escaping ((_ result: Swift.Result<Bool, Error>) -> Void)) {
        onBuyProductHandler = handler
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                let originalTransactionId = transaction.original?.transactionIdentifier ?? transaction.transactionIdentifier ?? ""
                print("IAP: restored (\(originalTransactionId))")
                onBuyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                totalRestoredPurchases += 1
                let restoredTransactionId = transaction.original?.transactionIdentifier ?? transaction.transactionIdentifier ?? ""
                print("IAP: restored id (\(restoredTransactionId))")
                
                let pay: [SKPaymentTransaction] = self.processTransactions(transactions)
                
                print("IAP: restored pay (\(pay))")
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(error))
                    } else {
                        onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
                    }
                    print("IAP Error:", error.localizedDescription)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing: print("IAP: Waiting response")
            @unknown default: break
            }
        }
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            onBuyProductHandler?(.success(true))
        } else {
            print("IAP: No purchases to restore!")
            onBuyProductHandler?(.success(false))
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                print("IAP Restore Error:", error.localizedDescription)
                onBuyProductHandler?(.failure(error))
            } else {
                onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
            }
        }
    }
    
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products: [SKProduct] = response.products

        // Check if there are any products available.
        if products.count > 0 {
            // Call the following handler passing the received products.
            onReceiveProductsHandler?(.success(products))
        } else {
            // No products were found.
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    
    
    func requestDidFinish(_ request: SKRequest) {
        // Implement this method OPTIONALLY and add any custom logic
        // you want to apply when a product request is finished.
    }
}

// MARK: - restorePurchases
extension IAPManager {
    
    func processTransactions(_ transactions: [SKPaymentTransaction]) -> [SKPaymentTransaction] {

        var unhandledTransactions: [SKPaymentTransaction] = []
        for transaction in transactions {
            print("productId \(transaction.transactionIdentifier) , quantity \(transaction.payment.quantity)")
            unhandledTransactions.append(transaction)
        }
        return unhandledTransactions
    }
}
