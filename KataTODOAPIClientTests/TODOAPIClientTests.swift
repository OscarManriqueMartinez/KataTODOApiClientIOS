//
//  TODOAPIClientTests.swift
//  KataTODOAPIClient
//
//  Created by Pedro Vicente Gomez on 12/02/16.
//  Copyright © 2016 Karumi. All rights reserved.
//

import Foundation
import Nocilla
import Nimble
import XCTest
import Result
@testable import KataTODOAPIClient

class TODOAPIClientTests: NocillaTestCase {

    private let apiClient = TODOAPIClient()

    func testSendsContentTypeHeader() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .withHeaders(["Content-Type": "application/json", "Accept": "application/json"])
            .andReturn(200)

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result).toEventuallyNot(beNil())
    }

    func testParsesTasksProperlyGettingAllTheTasks() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(200)
            .withBody(fromJSONFile("getTasksResponse"))

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.value?.count).toEventually(equal(200))
        assertTaskContainsExpectedValues((result?.value?[0])!)
    }

    func testReturnsNetworkErrorIfThereIsNoConnectionGettingAllTasks() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andFailWithError(NSError.networkError())

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.NetworkError))
    }

    func testReturnsUnknowErrorIfTheErrorIsNotHandledGettingAllTasks() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(418)

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.UnknownError(code: 418)))
    }

    func testParsesTaskProperlyGettingTaskById() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(200)
            .withBody(fromJSONFile("getTaskByIdResponse"))

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { response in
            result = response
        }

        expect(result).toEventuallyNot(beNil())
        assertTaskContainsExpectedValues((result?.value)!)
    }

    func testReturnsItemNotFoundErrorIfTheTaskIdDoesNotExist() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(404)

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.ItemNotFound))
    }

    func testReturnsNetworkErrorIfThereIsNoConnectionGettingTaskById() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andFailWithError(NSError.networkError())

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.NetworkError))
    }

    func testReturnsUnknowErrorIfTheErrorIsNotHandledGettingTasksById() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(418)

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.getTaskById("1") { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.UnknownError(code: 418)))
    }

    func testSendsTheCorrectBodyAddingANewTask() {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .withBody(fromJSONFile("addTaskToUserRequest"))
            .andReturn(201)

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "Finish this kata", completed: false) { response in
            result = response
        }

        expect(result).toEventuallyNot(beNil())
    }

    func testParsesTheTaskCreatedProperlyAddingANewTask() {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(201)
            .withBody(fromJSONFile("addTaskToUserResponse"))

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { response in
            result = response
        }

        expect(result).toEventuallyNot(beNil())
        assertTaskContainsExpectedValues((result?.value)!)
    }

    func testReturnsNetworkErrorIfThereIsNoConnection() {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andFailWithError(NSError.networkError())

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.NetworkError))
    }

    func testReturnsNetworkErrorIfThereIsNoConnectionAddinATask() {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andFailWithError(NSError.networkError())

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.NetworkError))
    }

    func testReturnsUnknowErrorIfThereIsAnyErrorAddingATask() {
        stubRequest("POST", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(418)

        var result: Result<TaskDTO, TODOAPIClientError>?
        apiClient.addTaskToUser("1", title: "delectus aut autem", completed: false) { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.UnknownError(code: 418)))
    }

    func testDeletesATask() {
        stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(200)

        var result: Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("1") { response in
            result = response
        }

        expect(result).toEventuallyNot(beNil())
    }

    func testReturnsItemNotFoundIfThereIsNoTaskWithIdTheAssociateId() {
        stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(404)

        var result: Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("1") { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.ItemNotFound))
    }

    func testReturnsNetworkErrorIfThereIsNoConnectionDeletingTask() {
        stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/1")
            .andFailWithError(NSError.networkError())

        var result: Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("1") { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.NetworkError))
    }

    func testReturnsUnknownErrorIfThereIsAnyErrorDeletingTask() {
        stubRequest("DELETE", "http://jsonplaceholder.typicode.com/todos/1")
            .andReturn(418)

        var result: Result<Void, TODOAPIClientError>?
        apiClient.deleteTaskById("1") { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.UnknownError(code: 418)))
    }

    private func assertTaskContainsExpectedValues(task: TaskDTO) {
        expect(task.id).to(equal("1"))
        expect(task.userId).to(equal("1"))
        expect(task.title).to(equal("delectus aut autem"))
        expect(task.completed).to(beFalse())
    }

}
