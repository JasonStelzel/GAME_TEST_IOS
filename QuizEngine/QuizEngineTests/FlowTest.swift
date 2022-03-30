//
//  FlowTest.swift
//  QuizEngineTests
//
//  Created by Jason Stelzel on 3/23/22.
//

import Foundation
import XCTest
@testable import QuizEngine


class FlowTest: XCTestCase {
    let router = RouterSpy()

    func test_start_withNoQuestions_doesNotRouteToQuestions() {
        makeSUT(questions: []).start() // system under test (sut)

        XCTAssertTrue(router.routedQuestions.isEmpty)
    }
    
    func test_start_withOneQuestion_routesToCorrectQuestion() {
        makeSUT(questions: ["Q1"]).start()
        
        XCTAssertEqual(router.routedQuestions, ["Q1"])
    }
    
    func test_start_withOneQuestion_routesToCorrectQuestion_2() {
        makeSUT(questions: ["Q2"]).start()

        XCTAssertEqual(router.routedQuestions, ["Q2"])
    }
    
    func test_start_withTwoQuestions_routesToFirstQuestion() {
        makeSUT(questions: ["Q1", "Q2"]).start()

        XCTAssertEqual(router.routedQuestions, ["Q1"])
    }
    
    func test_start_withTwoQuestions_routesToFirstQuestionTwice() {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        
        sut.start()
        sut.start()

        XCTAssertEqual(router.routedQuestions, ["Q1", "Q1"])
    }
    
    func test_startAndAnswerFirstAndSecondQuestion_withThreeQuestions_routesToSecondAndThirdQuestion() {
        let sut = makeSUT(questions: ["Q1", "Q2", "Q3"])
        // makeSUT(questions: ["Q1", "Q2"]).start() // will fail because SUT must be captured
        sut.start()
        
        router.answerCallback("A1")
        router.answerCallback("A2")

        XCTAssertEqual(router.routedQuestions, ["Q1", "Q2", "Q3"])
    }
    
    func test_startAndAnswerFirstQuestion_withOneQuestions_doesNotRoutesToAnotherQuestion() {
        let sut = makeSUT(questions: ["Q1"])
        // makeSUT(questions: ["Q1", "Q2"]).start() // will fail because SUT must be captured
        sut.start()
        
        router.answerCallback("A1")

        XCTAssertEqual(router.routedQuestions, ["Q1"])
    }
    
    func test_start_withNoQuestions_routesToResult() {
        makeSUT(questions: []).start()

        XCTAssertEqual(router.routedResult!, [:])
    }
    
    func test_start_withOneQuestion_doesNotRouteToResult() {
        makeSUT(questions: ["Q1"]).start()

        XCTAssertNil(router.routedResult)
    }
    
    func test_startAndAnswerFirstQuestion_withTwoQuestions_doesNotouteToResult() {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        // makeSUT(questions: ["Q1", "Q2"]).start() // will fail because SUT must be captured
        sut.start()
        
        router.answerCallback("A1")

        XCTAssertNil(router.routedResult)
    }
    
    func test_startAndAnswerFirstAndSecondQuestion_withTwoQuestions_routesToResult() {
        let sut = makeSUT(questions: ["Q1", "Q2"])
        // makeSUT(questions: ["Q1", "Q2"]).start() // will fail because SUT must be captured
        sut.start()
        
        router.answerCallback("A1")
        router.answerCallback("A2")

        XCTAssertEqual(router.routedResult, ["Q1": "A1", "Q2": "A2"])
    }
    

    // MARK: Helpers
    
    func makeSUT(questions: [String]) -> Flow {
        return Flow(questions: questions, router: router)
    }

    class RouterSpy: Router {
        var routedQuestions: [String] = []
        var routedResult: [String: String]? = nil
        
        var answerCallback: (Router.AnswerCallback) = { _ in }
        
        func routeTo(question: String, answerCallback: @escaping Router.AnswerCallback) {
            routedQuestions.append(question)
            self.answerCallback = answerCallback
        }
        
        func routeTo(result: [String : String]) {
            routedResult = result
        }
    }
}
