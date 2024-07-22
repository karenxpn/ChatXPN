//
//  File.swift
//  
//
//  Created by Karen Mirakyan on 14.05.24.
//

import Foundation
import FirebaseFirestore
import NotraAuth

extension APIHelper {
    func snapshotListener<T: IdentifiableDocument>(query: Query, completion: @escaping (Result<[T], any Error>) -> ()) {
        query.addSnapshotListener { snapshot, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print(error)
                }
                return
            }
            
            guard snapshot?.documents.last != nil else {
                DispatchQueue.main.async {
                    completion(.success(([])))
                }
                // The collection is empty.
                return
            }
            
            var results = [T]()
            
            snapshot?.documents.forEach({ doc in
                do {
                    let chat = try doc.data(as: T.self)
                    results.append(chat)
                } catch {
                    print(error)
                }
            })
            
            DispatchQueue.main.async {
                completion(.success(results))
            }
        }
    }
    
    func paginatedSnapshotListener<T: IdentifiableDocument>(query: Query, completion: @escaping(Result<([T], QueryDocumentSnapshot?), Error>) -> ()) {
        query.addSnapshotListener { snapshot, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard snapshot?.documents.last != nil else {
                DispatchQueue.main.async {
                    completion(.success(([], nil)))
                }
                // The collection is empty.
                return
            }
            
            var results = [(T)]()
            snapshot?.documents.forEach({ doc in
                do {
                    let message = try doc.data(as: T.self)
                    results.append(message)
                } catch {
                    print(error)
                }
            })
            
            DispatchQueue.main.async {
                completion(.success((results, snapshot?.documents.last)))
            }
        }
    }
}
