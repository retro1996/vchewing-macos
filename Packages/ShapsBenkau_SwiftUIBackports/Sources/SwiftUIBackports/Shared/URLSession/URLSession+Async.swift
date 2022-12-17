// (c) 2022 and onwards Shaps Benkau (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import Foundation

@available(macOS 10.15, *)
@available(iOS, deprecated: 15.0)
@available(macOS, deprecated: 12.0)
@available(tvOS, deprecated: 15.0)
@available(watchOS, deprecated: 8.0)
extension Backport where Wrapped: URLSession {
  /// Start a data task with a URL using async/await.
  /// - parameter url: The URL to send a request to.
  /// - returns: A tuple containing the binary `Data` that was downloaded,
  ///   as well as a `URLResponse` representing the server's response.
  /// - throws: Any error encountered while performing the data task.
  public func data(from url: URL) async throws -> (Data, URLResponse) {
    try await data(for: URLRequest(url: url))
  }

  /// Start a data task with a `URLRequest` using async/await.
  /// - parameter request: The `URLRequest` that the data task should perform.
  /// - returns: A tuple containing the binary `Data` that was downloaded,
  ///   as well as a `URLResponse` representing the server's response.
  /// - throws: Any error encountered while performing the data task.
  public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    let sessionTask = URLSessionTaskActor()

    return try await withTaskCancellationHandler {
      Task { await sessionTask.cancel() }
    } operation: {
      try await withCheckedThrowingContinuation { continuation in
        Task {
          await sessionTask.start(
            content.dataTask(with: request) { data, response, error in
              guard let data = data, let response = response else {
                let error = error ?? URLError(.badServerResponse)
                continuation.resume(throwing: error)
                return
              }

              continuation.resume(returning: (data, response))
            })
        }
      }
    }
  }

  public func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
    let sessionTask = URLSessionTaskActor()
    return try await withTaskCancellationHandler {
      Task { await sessionTask.cancel() }
    } operation: {
      try await withCheckedThrowingContinuation { continuation in
        Task {
          await sessionTask.start(
            content.uploadTask(with: request, fromFile: fileURL) { data, response, error in
              guard let data = data, let response = response else {
                let error = error ?? URLError(.badServerResponse)
                return continuation.resume(throwing: error)
              }

              continuation.resume(returning: (data, response))
            })
        }
      }
    }
  }

  public func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
    let sessionTask = URLSessionTaskActor()
    return try await withTaskCancellationHandler {
      Task { await sessionTask.cancel() }
    } operation: {
      try await withCheckedThrowingContinuation { continuation in
        Task {
          await sessionTask.start(
            content.uploadTask(with: request, from: bodyData) { data, response, error in
              guard let data = data, let response = response else {
                let error = error ?? URLError(.badServerResponse)
                return continuation.resume(throwing: error)
              }

              continuation.resume(returning: (data, response))
            })
        }
      }
    }
  }

  public func download(for request: URLRequest) async throws -> (URL, URLResponse) {
    let sessionTask = URLSessionTaskActor()
    return try await withTaskCancellationHandler {
      Task { await sessionTask.cancel() }
    } operation: {
      try await withCheckedThrowingContinuation { continuation in
        Task {
          await sessionTask.start(
            content.downloadTask(with: request) { data, response, error in
              guard let data = data, let response = response else {
                let error = error ?? URLError(.badServerResponse)
                return continuation.resume(throwing: error)
              }

              continuation.resume(returning: (data, response))
            })
        }
      }
    }
  }

  public func download(from url: URL) async throws -> (URL, URLResponse) {
    let sessionTask = URLSessionTaskActor()
    return try await withTaskCancellationHandler {
      Task { await sessionTask.cancel() }
    } operation: {
      try await withCheckedThrowingContinuation { continuation in
        Task {
          await sessionTask.start(
            content.downloadTask(with: url) { data, response, error in
              guard let data = data, let response = response else {
                let error = error ?? URLError(.badServerResponse)
                return continuation.resume(throwing: error)
              }

              continuation.resume(returning: (data, response))
            })
        }
      }
    }
  }

  public func download(resumeFrom resumeData: Data) async throws -> (URL, URLResponse) {
    let sessionTask = URLSessionTaskActor()
    return try await withTaskCancellationHandler {
      Task { await sessionTask.cancel() }
    } operation: {
      try await withCheckedThrowingContinuation { continuation in
        Task {
          await sessionTask.start(
            content.downloadTask(withResumeData: resumeData) { data, response, error in
              guard let data = data, let response = response else {
                let error = error ?? URLError(.badServerResponse)
                return continuation.resume(throwing: error)
              }

              continuation.resume(returning: (data, response))
            })
        }
      }
    }
  }
}

@available(macOS 10.15, *)
private actor URLSessionTaskActor {
  weak var task: URLSessionTask?

  func start(_ task: URLSessionTask) {
    self.task = task
    task.resume()
  }

  func cancel() {
    task?.cancel()
  }
}
