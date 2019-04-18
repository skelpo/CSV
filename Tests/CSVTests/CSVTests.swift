import XCTest
@testable import CSV

class CSVTests: XCTestCase {
    func testParseSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)

        // 9.142
        measure {
            let _: [CSV.Column] = CSV.parse(data)
        }
    }

    func testAsyncParseSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Array(Data(contentsOf: url))
        let parser = CSV.SyncParser()

        // 10.473
        measure {
            _ = parser.parse(data)
        }
    }

    func testAsyncParseStringSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try String(contentsOf: url)
        let parser = CSV.SyncParser()

        // 18.083
        measure {
            _ = parser.parse(data)
        }
    }
    
    func testParse()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        let parsed: [CSV.Column] = CSV.parse(data)
        
        let lastRow = parsed.reduce(into: [:]) { result, column in
            result[column.header] = column.fields.last ?? nil
        }
        let expected = [
            "YearsCodingProf": "NA", "AgreeDisagree1": "NA", "AssessBenefits5": "NA", "FormalEducation": "NA", "StackOverflowDevStory": "NA",
            "CommunicationTools": "NA", "CompanySize": "NA", "Dependents": "NA", "HypotheticalTools2": "NA", "AssessBenefits7": "NA",
            "SurveyEasy": "NA", "UpdateCV": "NA", "AIInteresting": "NA", "CheckInCode": "NA", "UndergradMajor": "NA", "OpenSource": "Yes",
            "JobEmailPriorities1": "NA", "SalaryType": "NA", "HypotheticalTools4": "NA", "TimeFullyProductive": "NA", "SkipMeals": "NA",
            "AdsPriorities4": "NA", "YearsCoding": "NA", "AdsPriorities6": "NA", "StackOverflowJobs": "NA", "Student": "NA", "AssessJob9": "NA",
            "AssessBenefits2": "NA", "Country": "Cambodia", "MilitaryUS": "NA", "AssessBenefits1": "NA", "AdsPriorities7": "NA",
            "SexualOrientation": "NA", "LastNewJob": "NA", "Salary": "NA", "SurveyTooLong": "NA", "DatabaseDesireNextYear": "NA",
            "ConvertedSalary": "NA", "AdsAgreeDisagree3": "NA", "AssessBenefits4": "NA", "StackOverflowRecommend": "NA", "AdBlockerReasons": "NA",
            "Respondent": "101548", "HoursOutside": "NA", "CareerSatisfaction": "NA", "HopeFiveYears": "NA", "JobContactPriorities2": "NA",
            "TimeAfterBootcamp": "NA", "JobContactPriorities3": "NA", "AdsPriorities3": "NA", "AssessJob2": "NA", "AssessJob6": "NA",
            "AdsPriorities1": "NA", "AdsActions": "NA", "Exercise": "NA", "AssessJob8": "NA", "JobSearchStatus": "NA", "JobSatisfaction": "NA",
            "JobContactPriorities4": "NA", "HackathonReasons": "NA", "RaceEthnicity": "NA", "LanguageWorkedWith": "NA", "AIFuture": "NA",
            "HoursComputer": "NA", "FrameworkDesireNextYear": "NA", "HypotheticalTools1": "NA", "Currency": "NA", "AgreeDisagree2": "NA",
            "Employment": "NA", "HypotheticalTools3": "NA", "IDE": "NA", "SelfTaughtTypes": "NA", "AssessJob10": "NA", "AIResponsible": "NA",
            "DevType": "NA", "HypotheticalTools5": "NA", "AdsAgreeDisagree1": "NA", "EthicsResponsible": "NA", "EducationTypes": "NA",
            "AdsPriorities5": "NA", "EthicalImplications": "NA", "AssessBenefits3": "NA", "JobEmailPriorities2": "NA", "EducationParents": "NA",
            "WakeTime": "NA", "EthicsChoice": "NA", "StackOverflowVisit": "NA", "StackOverflowJobsRecommend": "NA", "PlatformDesireNextYear": "NA",
            "StackOverflowParticipate": "NA", "Methodology": "NA", "AssessBenefits11": "NA", "StackOverflowHasAccount": "NA",
            "OperatingSystem": "NA", "FrameworkWorkedWith": "NA", "EthicsReport": "NA", "StackOverflowConsiderMember": "NA",
            "AdsAgreeDisagree2": "NA", "AssessBenefits10": "NA", "AssessJob4": "NA", "JobEmailPriorities7": "NA", "AssessJob7": "NA",
            "AssessJob1": "NA", "Age": "NA", "Gender": "NA", "JobContactPriorities5": "NA", "AdBlockerDisable": "NA", "VersionControl": "NA",
            "JobContactPriorities1": "NA", "JobEmailPriorities5": "NA", "DatabaseWorkedWith": "NA", "PlatformWorkedWith": "NA",
            "AssessBenefits6": "NA", "AssessJob5": "NA", "JobEmailPriorities4": "NA", "CurrencySymbol": "NA", "ErgonomicDevices": "NA",
            "LanguageDesireNextYear": "NA", "AgreeDisagree3": "NA", "AIDangerous": "NA", "JobEmailPriorities3": "NA", "NumberMonitors": "NA",
            "Hobby": "Yes", "JobEmailPriorities6": "NA", "AdsPriorities2": "NA", "AdBlocker": "NA", "AssessJob3": "NA", "AssessBenefits8": "NA",
            "AssessBenefits9": "NA"
        ]
        
        for (parsed, expected) in zip(lastRow.sorted(by: { $0.key < $1.key }), expected.sorted(by: { $0.key < $1.key })) {
            XCTAssertEqual(parsed.key, expected.key)
            XCTAssertEqual(parsed.value, expected.value)
        }
    }
    
    func testRowIterate()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Array(Data(contentsOf: url))
        
        measure {
            do {
                let container = try DecoderDataContainer(data: data)
                while container.row != nil {
                    container.incremetRow()
                }
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testCSVDecode()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)

        let decodingOptions = CSVCodingOptions(boolCodingStrategy: .fuzzy, nilCodingStrategy: .custom("NA"))
        let decoder = CSVCoder(decodingOptions: decodingOptions)

        let responses = try decoder.decode(data, to: Response.self)
        self.compare(responses.first, to: .first)
        self.compare(responses.last, to: .last)
    }
    
    func testCSVDecodeSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)

        let decodingOptions = CSVCodingOptions(boolCodingStrategy: .fuzzy, nilCodingStrategy: .custom("NA"))
        let decoder = CSVCoder(decodingOptions: decodingOptions)

        // 18.489
        measure {
            do {
                _ = try decoder.decode(data, to: Response.self)
            } catch { XCTFail(error.localizedDescription) }
        }
    }

    func testCSVSyncDecodeSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)

        let decodingOptions = CSVCodingOptions(boolCodingStrategy: .fuzzy, nilCodingStrategy: .custom("NA"))
        let decoder = CSVDecoder(decodingOptions: decodingOptions)

        // 20.948
        measure {
            do {
                _ = try decoder.sync.decode(Response.self, from: data)
            } catch { XCTFail(error.localizedDescription) }
        }
    }

    func testCSVColumnSeralization()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        let parsed: [CSV.Column] = CSV.parse(data)
        let _ = parsed.seralize()
    }
    
    func testCSVColumnSeralizationSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)
        let parsed: [CSV.Column] = CSV.parse(data)

        // 11.932
        measure {
            _ = parsed.seralize()
        }
    }

    func testCSVSyncSeralizationSpeed() throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Array(Data(contentsOf: url))
        let parsed = CSV.SyncParser().parse(data)
        let serializer = SyncSerializer()

        // 18.049
        measure {
            _ = serializer.serialize(parsed)
        }
    }

    func testCSVEncoding()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)

        let decodingOptions = CSVCodingOptions(boolCodingStrategy: .fuzzy, nilCodingStrategy: .custom("NA"))
        let decoder = CSVCoder(decodingOptions: decodingOptions)

        let fielders = try decoder.decode(data, to: Response.self)
        _ = try decoder.encode(fielders)
    }

    func testCSVEncodingSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)

        let decodingOptions = CSVCodingOptions(boolCodingStrategy: .fuzzy, nilCodingStrategy: .custom("NA"))
        let decoder = CSVCoder(decodingOptions: decodingOptions)

        let fielders = try decoder.decode(data, to: Response.self)

        // 9.477
        measure {
            do {
                _ = try decoder.encode(fielders)
            } catch { XCTFail(error.localizedDescription) }
        }
    }

    func testCSVSyncEncodingSpeed() throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Data(contentsOf: url)

        let decodingOptions = CSVCodingOptions(boolCodingStrategy: .fuzzy, nilCodingStrategy: .custom("NA"))
        let decoder = CSVDecoder(decodingOptions: decodingOptions)

        let fielders = try decoder.sync.decode(Response.self, from: data)

        let encodingOptions = CSVCodingOptions(boolCodingStrategy: .fuzzy, nilCodingStrategy: .custom("NA"))
        let encoder = CSVEncoder(encodingOptions: encodingOptions)

        // 12.898
        measure {
            do {
                _ = try encoder.sync.encode(fielders)
            } catch { XCTFail(error.localizedDescription) }
        }
    }

    func testDataToIntSpeed() {
        let bytes = "12495768014".bytes
        measure {
            for _ in  0...1_000_000 {
                guard let _ = bytes.int else {
                    XCTFail()
                    return
                }
            }
        }
        
        XCTAssertEqual(bytes.int, 12495768014)
    }
    
    func testBytesToStringSpeed() {
        let bytes: [UInt8] = [49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 97, 115, 100, 102, 103, 104, 106, 107, 108, 122, 120, 99, 118, 98, 110, 109]
        measure {
            for _ in 0...1_000_000 {
                _ = String(bytes)
            }
        }
        
        guard let result = String(bytes: bytes, encoding: .utf8) else {
            XCTFail()
            return
        }
        XCTAssertEqual(String(data: Data(bytes), encoding: .utf8), result)
    }
    
    func testKeyinitSpeed()throws {
        let url = URL(string: "file:/Users/calebkleveter/Development/developer_survey_2018.csv")!
        let data = try Array(Data(contentsOf: url))
        
        measure {
            autoreleasepool {
                _ = data.split(separator: "\n").count
            }
        }
    }
    
    static var allTests = [
        ("testParseSpeed", testParseSpeed),
        ("testRowIterate", testRowIterate),
        ("testCSVDecode", testCSVDecode),
        ("testCSVDecodeSpeed", testCSVDecodeSpeed),
        ("testCSVColumnSeralization", testCSVColumnSeralization),
        ("testCSVColumnSeralizationSpeed", testCSVColumnSeralizationSpeed),
        ("testCSVEncoding", testCSVEncoding),
        ("testCSVEncodingSpeed", testCSVEncodingSpeed),
        ("testDataToIntSpeed", testDataToIntSpeed),
        ("testBytesToStringSpeed", testBytesToStringSpeed)
    ]
    
    func compare(_ lhs: Response?, to rhs: Response?) {
        XCTAssertEqual(lhs?.Respondent, rhs?.Respondent)
        XCTAssertEqual(lhs?.Hobby, rhs?.Hobby)
        XCTAssertEqual(lhs?.OpenSource, rhs?.OpenSource)
        XCTAssertEqual(lhs?.Country, rhs?.Country)
        XCTAssertEqual(lhs?.Student, rhs?.Student)
        XCTAssertEqual(lhs?.Employment, rhs?.Employment)
        XCTAssertEqual(lhs?.FormalEducation, rhs?.FormalEducation)
        XCTAssertEqual(lhs?.UndergradMajor, rhs?.UndergradMajor)
        XCTAssertEqual(lhs?.CompanySize, rhs?.CompanySize)
        XCTAssertEqual(lhs?.DevType, rhs?.DevType)
        XCTAssertEqual(lhs?.YearsCoding, rhs?.YearsCoding)
        XCTAssertEqual(lhs?.YearsCodingProf, rhs?.YearsCodingProf)
        XCTAssertEqual(lhs?.JobSatisfaction, rhs?.JobSatisfaction)
        XCTAssertEqual(lhs?.CareerSatisfaction, rhs?.CareerSatisfaction)
        XCTAssertEqual(lhs?.HopeFiveYears, rhs?.HopeFiveYears)
        XCTAssertEqual(lhs?.JobSearchStatus, rhs?.JobSearchStatus)
        XCTAssertEqual(lhs?.LastNewJob, rhs?.LastNewJob)
        XCTAssertEqual(lhs?.AssessJob1, rhs?.AssessJob1)
        XCTAssertEqual(lhs?.AssessJob2, rhs?.AssessJob2)
        XCTAssertEqual(lhs?.AssessJob3, rhs?.AssessJob3)
        XCTAssertEqual(lhs?.AssessJob4, rhs?.AssessJob4)
        XCTAssertEqual(lhs?.AssessJob5, rhs?.AssessJob5)
        XCTAssertEqual(lhs?.AssessJob6, rhs?.AssessJob6)
        XCTAssertEqual(lhs?.AssessJob7, rhs?.AssessJob7)
        XCTAssertEqual(lhs?.AssessJob8, rhs?.AssessJob8)
        XCTAssertEqual(lhs?.AssessJob9, rhs?.AssessJob9)
        XCTAssertEqual(lhs?.AssessJob10, rhs?.AssessJob10)
        XCTAssertEqual(lhs?.AssessBenefits1, rhs?.AssessBenefits1)
        XCTAssertEqual(lhs?.AssessBenefits2, rhs?.AssessBenefits2)
        XCTAssertEqual(lhs?.AssessBenefits3, rhs?.AssessBenefits3)
        XCTAssertEqual(lhs?.AssessBenefits4, rhs?.AssessBenefits4)
        XCTAssertEqual(lhs?.AssessBenefits5, rhs?.AssessBenefits5)
        XCTAssertEqual(lhs?.AssessBenefits6, rhs?.AssessBenefits6)
        XCTAssertEqual(lhs?.AssessBenefits7, rhs?.AssessBenefits7)
        XCTAssertEqual(lhs?.AssessBenefits8, rhs?.AssessBenefits8)
        XCTAssertEqual(lhs?.AssessBenefits9, rhs?.AssessBenefits9)
        XCTAssertEqual(lhs?.AssessBenefits10, rhs?.AssessBenefits10)
        XCTAssertEqual(lhs?.AssessBenefits11, rhs?.AssessBenefits11)
        XCTAssertEqual(lhs?.JobContactPriorities1, rhs?.JobContactPriorities1)
        XCTAssertEqual(lhs?.JobContactPriorities2, rhs?.JobContactPriorities2)
        XCTAssertEqual(lhs?.JobContactPriorities3, rhs?.JobContactPriorities3)
        XCTAssertEqual(lhs?.JobContactPriorities4, rhs?.JobContactPriorities4)
        XCTAssertEqual(lhs?.JobContactPriorities5, rhs?.JobContactPriorities5)
        XCTAssertEqual(lhs?.JobEmailPriorities1, rhs?.JobEmailPriorities1)
        XCTAssertEqual(lhs?.JobEmailPriorities2, rhs?.JobEmailPriorities2)
        XCTAssertEqual(lhs?.JobEmailPriorities3, rhs?.JobEmailPriorities3)
        XCTAssertEqual(lhs?.JobEmailPriorities4, rhs?.JobEmailPriorities4)
        XCTAssertEqual(lhs?.JobEmailPriorities5, rhs?.JobEmailPriorities5)
        XCTAssertEqual(lhs?.JobEmailPriorities6, rhs?.JobEmailPriorities6)
        XCTAssertEqual(lhs?.JobEmailPriorities7, rhs?.JobEmailPriorities7)
        XCTAssertEqual(lhs?.UpdateCV, rhs?.UpdateCV)
        XCTAssertEqual(lhs?.Currency, rhs?.Currency)
        XCTAssertEqual(lhs?.Salary, rhs?.Salary)
        XCTAssertEqual(lhs?.SalaryType, rhs?.SalaryType)
        XCTAssertEqual(lhs?.ConvertedSalary, rhs?.ConvertedSalary)
        XCTAssertEqual(lhs?.CurrencySymbol, rhs?.CurrencySymbol)
        XCTAssertEqual(lhs?.CommunicationTools, rhs?.CommunicationTools)
        XCTAssertEqual(lhs?.TimeFullyProductive, rhs?.TimeFullyProductive)
        XCTAssertEqual(lhs?.EducationTypes, rhs?.EducationTypes)
        XCTAssertEqual(lhs?.SelfTaughtTypes, rhs?.SelfTaughtTypes)
        XCTAssertEqual(lhs?.TimeAfterBootcamp, rhs?.TimeAfterBootcamp)
        XCTAssertEqual(lhs?.HackathonReasons, rhs?.HackathonReasons)
        XCTAssertEqual(lhs?.AgreeDisagree1, rhs?.AgreeDisagree1)
        XCTAssertEqual(lhs?.AgreeDisagree2, rhs?.AgreeDisagree2)
        XCTAssertEqual(lhs?.AgreeDisagree3, rhs?.AgreeDisagree3)
        XCTAssertEqual(lhs?.LanguageWorkedWith, rhs?.LanguageWorkedWith)
        XCTAssertEqual(lhs?.LanguageDesireNextYear, rhs?.LanguageDesireNextYear)
        XCTAssertEqual(lhs?.DatabaseWorkedWith, rhs?.DatabaseWorkedWith)
        XCTAssertEqual(lhs?.DatabaseDesireNextYear, rhs?.DatabaseDesireNextYear)
        XCTAssertEqual(lhs?.PlatformWorkedWith, rhs?.PlatformWorkedWith)
        XCTAssertEqual(lhs?.PlatformDesireNextYear, rhs?.PlatformDesireNextYear)
        XCTAssertEqual(lhs?.FrameworkWorkedWith, rhs?.FrameworkWorkedWith)
        XCTAssertEqual(lhs?.FrameworkDesireNextYear, rhs?.FrameworkDesireNextYear)
        XCTAssertEqual(lhs?.IDE, rhs?.IDE)
        XCTAssertEqual(lhs?.OperatingSystem, rhs?.OperatingSystem)
        XCTAssertEqual(lhs?.NumberMonitors, rhs?.NumberMonitors)
        XCTAssertEqual(lhs?.Methodology, rhs?.Methodology)
        XCTAssertEqual(lhs?.VersionControl, rhs?.VersionControl)
        XCTAssertEqual(lhs?.CheckInCode, rhs?.CheckInCode)
        XCTAssertEqual(lhs?.AdBlocker, rhs?.AdBlocker)
        XCTAssertEqual(lhs?.AdBlockerDisable, rhs?.AdBlockerDisable)
        XCTAssertEqual(lhs?.AdBlockerReasons, rhs?.AdBlockerReasons)
        XCTAssertEqual(lhs?.AdsAgreeDisagree1, rhs?.AdsAgreeDisagree1)
        XCTAssertEqual(lhs?.AdsAgreeDisagree2, rhs?.AdsAgreeDisagree2)
        XCTAssertEqual(lhs?.AdsAgreeDisagree3, rhs?.AdsAgreeDisagree3)
        XCTAssertEqual(lhs?.AdsActions, rhs?.AdsActions)
        XCTAssertEqual(lhs?.AdsPriorities1, rhs?.AdsPriorities1)
        XCTAssertEqual(lhs?.AdsPriorities2, rhs?.AdsPriorities2)
        XCTAssertEqual(lhs?.AdsPriorities3, rhs?.AdsPriorities3)
        XCTAssertEqual(lhs?.AdsPriorities4, rhs?.AdsPriorities4)
        XCTAssertEqual(lhs?.AdsPriorities5, rhs?.AdsPriorities5)
        XCTAssertEqual(lhs?.AdsPriorities6, rhs?.AdsPriorities6)
        XCTAssertEqual(lhs?.AdsPriorities7, rhs?.AdsPriorities7)
        XCTAssertEqual(lhs?.AIDangerous, rhs?.AIDangerous)
        XCTAssertEqual(lhs?.AIInteresting, rhs?.AIInteresting)
        XCTAssertEqual(lhs?.AIResponsible, rhs?.AIResponsible)
        XCTAssertEqual(lhs?.AIFuture, rhs?.AIFuture)
        XCTAssertEqual(lhs?.EthicsChoice, rhs?.EthicsChoice)
        XCTAssertEqual(lhs?.EthicsReport, rhs?.EthicsReport)
        XCTAssertEqual(lhs?.EthicsResponsible, rhs?.EthicsResponsible)
        XCTAssertEqual(lhs?.EthicalImplications, rhs?.EthicalImplications)
        XCTAssertEqual(lhs?.StackOverflowRecommend, rhs?.StackOverflowRecommend)
        XCTAssertEqual(lhs?.StackOverflowVisit, rhs?.StackOverflowVisit)
        XCTAssertEqual(lhs?.StackOverflowHasAccount, rhs?.StackOverflowHasAccount)
        XCTAssertEqual(lhs?.StackOverflowParticipate, rhs?.StackOverflowParticipate)
        XCTAssertEqual(lhs?.StackOverflowJobs, rhs?.StackOverflowJobs)
        XCTAssertEqual(lhs?.StackOverflowDevStory, rhs?.StackOverflowDevStory)
        XCTAssertEqual(lhs?.StackOverflowJobsRecommend, rhs?.StackOverflowJobsRecommend)
        XCTAssertEqual(lhs?.StackOverflowConsiderMember, rhs?.StackOverflowConsiderMember)
        XCTAssertEqual(lhs?.HypotheticalTools1, rhs?.HypotheticalTools1)
        XCTAssertEqual(lhs?.HypotheticalTools2, rhs?.HypotheticalTools2)
        XCTAssertEqual(lhs?.HypotheticalTools3, rhs?.HypotheticalTools3)
        XCTAssertEqual(lhs?.HypotheticalTools4, rhs?.HypotheticalTools4)
        XCTAssertEqual(lhs?.HypotheticalTools5, rhs?.HypotheticalTools5)
        XCTAssertEqual(lhs?.WakeTime, rhs?.WakeTime)
        XCTAssertEqual(lhs?.HoursComputer, rhs?.HoursComputer)
        XCTAssertEqual(lhs?.HoursOutside, rhs?.HoursOutside)
        XCTAssertEqual(lhs?.SkipMeals, rhs?.SkipMeals)
        XCTAssertEqual(lhs?.ErgonomicDevices, rhs?.ErgonomicDevices)
        XCTAssertEqual(lhs?.Exercise, rhs?.Exercise)
        XCTAssertEqual(lhs?.Gender, rhs?.Gender)
        XCTAssertEqual(lhs?.SexualOrientation, rhs?.SexualOrientation)
        XCTAssertEqual(lhs?.EducationParents, rhs?.EducationParents)
        XCTAssertEqual(lhs?.RaceEthnicity, rhs?.RaceEthnicity)
        XCTAssertEqual(lhs?.Age, rhs?.Age)
        XCTAssertEqual(lhs?.Dependents, rhs?.Dependents)
        XCTAssertEqual(lhs?.MilitaryUS, rhs?.MilitaryUS)
        XCTAssertEqual(lhs?.SurveyTooLong, rhs?.SurveyTooLong)
        XCTAssertEqual(lhs?.SurveyEasy, rhs?.SurveyEasy)
    }
}

struct Response: Codable, Equatable {
    static func makeKeys(from row: [String: [[UInt8]?]]) -> [CodingKey] {
        // return row.compactMap { cell in return Response.CodingKeys.init(stringValue: cell.key) }
        return Array(row.keys).compactMap(Response.CodingKeys.init)
    }
    
    let Respondent: Int
    let Hobby: Bool
    let OpenSource: Bool
    let Country: String
    let Student: String
    let Employment: String
    let FormalEducation: String
    let UndergradMajor: String?
    let CompanySize: String
    let DevType: String
    let YearsCoding: String
    let YearsCodingProf: String?
    let JobSatisfaction: String?
    let CareerSatisfaction: String?
    let HopeFiveYears: String?
    let JobSearchStatus: String?
    let LastNewJob: String?
    let AssessJob1: Int?
    let AssessJob2: Int?
    let AssessJob3: Int?
    let AssessJob4: Int?
    let AssessJob5: Int?
    let AssessJob6: Int?
    let AssessJob7: Int?
    let AssessJob8: Int?
    let AssessJob9: Int?
    let AssessJob10: Int?
    let AssessBenefits1: Int?
    let AssessBenefits2: Int?
    let AssessBenefits3: Int?
    let AssessBenefits4: Int?
    let AssessBenefits5: Int?
    let AssessBenefits6: Int?
    let AssessBenefits7: Int?
    let AssessBenefits8: Int?
    let AssessBenefits9: Int?
    let AssessBenefits10: Int?
    let AssessBenefits11: Int?
    let JobContactPriorities1: Int?
    let JobContactPriorities2: Int?
    let JobContactPriorities3: Int?
    let JobContactPriorities4: Int?
    let JobContactPriorities5: Int?
    let JobEmailPriorities1: Int?
    let JobEmailPriorities2: Int?
    let JobEmailPriorities3: Int?
    let JobEmailPriorities4: Int?
    let JobEmailPriorities5: Int?
    let JobEmailPriorities6: Int?
    let JobEmailPriorities7: Int?
    let UpdateCV: String?
    let Currency: String?
    let Salary: Float?
    let SalaryType: String?
    let ConvertedSalary: String?
    let CurrencySymbol: String?
    let CommunicationTools: String?
    let TimeFullyProductive: String?
    let EducationTypes: String?
    let SelfTaughtTypes: String?
    let TimeAfterBootcamp: String?
    let HackathonReasons: String?
    let AgreeDisagree1: String?
    let AgreeDisagree2: String?
    let AgreeDisagree3: String?
    let LanguageWorkedWith: String?
    let LanguageDesireNextYear: String?
    let DatabaseWorkedWith: String?
    let DatabaseDesireNextYear: String?
    let PlatformWorkedWith: String?
    let PlatformDesireNextYear: String?
    let FrameworkWorkedWith: String?
    let FrameworkDesireNextYear: String?
    let IDE: String?
    let OperatingSystem: String?
    let NumberMonitors: String?
    let Methodology: String?
    let VersionControl: String?
    let CheckInCode: String?
    let AdBlocker: String?
    let AdBlockerDisable: String?
    let AdBlockerReasons: String?
    let AdsAgreeDisagree1: String?
    let AdsAgreeDisagree2: String?
    let AdsAgreeDisagree3: String?
    let AdsActions: String?
    let AdsPriorities1: Int?
    let AdsPriorities2: Int?
    let AdsPriorities3: Int?
    let AdsPriorities4: Int?
    let AdsPriorities5: Int?
    let AdsPriorities6: Int?
    let AdsPriorities7: Int?
    let AIDangerous: String?
    let AIInteresting: String?
    let AIResponsible: String?
    let AIFuture: String?
    let EthicsChoice: String?
    let EthicsReport: String?
    let EthicsResponsible: String?
    let EthicalImplications: String?
    let StackOverflowRecommend: String?
    let StackOverflowVisit: String?
    let StackOverflowHasAccount: String?
    let StackOverflowParticipate: String?
    let StackOverflowJobs: String?
    let StackOverflowDevStory: String?
    let StackOverflowJobsRecommend: String?
    let StackOverflowConsiderMember: String?
    let HypotheticalTools1: String?
    let HypotheticalTools2: String?
    let HypotheticalTools3: String?
    let HypotheticalTools4: String?
    let HypotheticalTools5: String?
    let WakeTime: String?
    let HoursComputer: String?
    let HoursOutside: String?
    let SkipMeals: String?
    let ErgonomicDevices: String?
    let Exercise: String?
    let Gender: String?
    let SexualOrientation: String?
    let EducationParents: String?
    let RaceEthnicity: String?
    let Age: String?
    let Dependents: Bool?
    let MilitaryUS: Bool?
    let SurveyTooLong: String?
    let SurveyEasy: String
    
    static let first = Response(
        Respondent: 1,
        Hobby: true,
        OpenSource: false,
        Country: "Kenya",
        Student: "No",
        Employment: "Employed part-time",
        FormalEducation: "Bachelor’s degree (BA, BS, B.Eng., etc.)",
        UndergradMajor: "Mathematics or statistics",
        CompanySize: "20 to 99 employees",
        DevType: "Full-stack developer",
        YearsCoding: "3-5 years",
        YearsCodingProf: "3-5 years",
        JobSatisfaction: "Extremely satisfied",
        CareerSatisfaction: "Extremely satisfied",
        HopeFiveYears: "Working as a founder or co-founder of my own company",
        JobSearchStatus: "I’m not actively looking, but I am open to new opportunities",
        LastNewJob: "Less than a year ago",
        AssessJob1: 10,
        AssessJob2: 7,
        AssessJob3: 8,
        AssessJob4: 1,
        AssessJob5: 2,
        AssessJob6: 5,
        AssessJob7: 3,
        AssessJob8: 4,
        AssessJob9: 9,
        AssessJob10: 6,
        AssessBenefits1: nil,
        AssessBenefits2: nil,
        AssessBenefits3: nil,
        AssessBenefits4: nil,
        AssessBenefits5: nil,
        AssessBenefits6: nil,
        AssessBenefits7: nil,
        AssessBenefits8: nil,
        AssessBenefits9: nil,
        AssessBenefits10: nil,
        AssessBenefits11: nil,
        JobContactPriorities1: 3,
        JobContactPriorities2: 1,
        JobContactPriorities3: 4,
        JobContactPriorities4: 2,
        JobContactPriorities5: 5,
        JobEmailPriorities1: 5,
        JobEmailPriorities2: 6,
        JobEmailPriorities3: 7,
        JobEmailPriorities4: 2,
        JobEmailPriorities5: 1,
        JobEmailPriorities6: 4,
        JobEmailPriorities7: 3,
        UpdateCV: "My job status or other personal status changed",
        Currency: nil,
        Salary: nil,
        SalaryType: "Monthly",
        ConvertedSalary: nil,
        CurrencySymbol: "KES",
        CommunicationTools: "Slack",
        TimeFullyProductive: "One to three months",
        EducationTypes: "Taught yourself a new language, framework, or tool without taking a formal course;Participated in a hackathon",
        SelfTaughtTypes: "The official documentation and/or standards for the technology;A book or e-book from O’Reilly, Apress, or a similar publisher;Questions & answers on Stack Overflow;Online developer communities other than Stack Overflow (ex. forums, listservs, IRC channels, etc.)",
        TimeAfterBootcamp: nil,
        HackathonReasons: "To build my professional network",
        AgreeDisagree1: "Strongly agree",
        AgreeDisagree2: "Strongly agree",
        AgreeDisagree3: "Neither Agree nor Disagree",
        LanguageWorkedWith: "JavaScript;Python;HTML;CSS",
        LanguageDesireNextYear: "JavaScript;Python;HTML;CSS",
        DatabaseWorkedWith: "Redis;SQL Server;MySQL;PostgreSQL;Amazon RDS/Aurora;Microsoft Azure (Tables, CosmosDB, SQL, etc)",
        DatabaseDesireNextYear: "Redis;SQL Server;MySQL;PostgreSQL;Amazon RDS/Aurora;Microsoft Azure (Tables, CosmosDB, SQL, etc)",
        PlatformWorkedWith: "AWS;Azure;Linux;Firebase",
        PlatformDesireNextYear: "AWS;Azure;Linux;Firebase",
        FrameworkWorkedWith: "Django;React",
        FrameworkDesireNextYear: "Django;React",
        IDE: "Komodo;Vim;Visual Studio Code",
        OperatingSystem: "Linux-based",
        NumberMonitors: "1",
        Methodology: "Agile;Scrum",
        VersionControl: "Git",
        CheckInCode: "Multiple times per day",
        AdBlocker: "Yes",
        AdBlockerDisable: "No",
        AdBlockerReasons: nil,
        AdsAgreeDisagree1: "Strongly agree",
        AdsAgreeDisagree2: "Strongly agree",
        AdsAgreeDisagree3: "Strongly agree",
        AdsActions: "Saw an online advertisement and then researched it (without clicking on the ad);Stopped going to a website because of their advertising",
        AdsPriorities1: 1,
        AdsPriorities2: 5,
        AdsPriorities3: 4,
        AdsPriorities4: 7,
        AdsPriorities5: 2,
        AdsPriorities6: 6,
        AdsPriorities7: 3,
        AIDangerous: "Artificial intelligence surpassing human intelligence (the singularity)",
        AIInteresting: "Algorithms making important decisions",
        AIResponsible: "The developers or the people creating the AI",
        AIFuture: "I'm excited about the possibilities more than worried about the dangers.",
        EthicsChoice: "No",
        EthicsReport: "Yes, and publicly",
        EthicsResponsible: "Upper management at the company/organization",
        EthicalImplications: "Yes",
        StackOverflowRecommend: "10 (Very Likely)",
        StackOverflowVisit: "Multiple times per day",
        StackOverflowHasAccount: "Yes",
        StackOverflowParticipate: "I have never participated in Q&A on Stack Overflow",
        StackOverflowJobs: "No, I knew that Stack Overflow had a jobs board but have never used or visited it",
        StackOverflowDevStory: "Yes",
        StackOverflowJobsRecommend: nil,
        StackOverflowConsiderMember: "Yes",
        HypotheticalTools1: "Extremely interested",
        HypotheticalTools2: "Extremely interested",
        HypotheticalTools3: "Extremely interested",
        HypotheticalTools4: "Extremely interested",
        HypotheticalTools5: "Extremely interested",
        WakeTime: "Between 5:00 - 6:00 AM",
        HoursComputer: "9 - 12 hours",
        HoursOutside: "1 - 2 hours",
        SkipMeals: "Never",
        ErgonomicDevices: "Standing desk",
        Exercise: "3 - 4 times per week",
        Gender: "Male",
        SexualOrientation: "Straight or heterosexual",
        EducationParents: "Bachelor’s degree (BA, BS, B.Eng., etc.)",
        RaceEthnicity: "Black or of African descent",
        Age: "25 - 34 years old",
        Dependents: true,
        MilitaryUS: nil,
        SurveyTooLong: "The survey was an appropriate length",
        SurveyEasy: "Very easy"
    )
    
    static let last = Response(
        Respondent: 101548,
        Hobby: true,
        OpenSource: true,
        Country: "Cambodia",
        Student: "NA",
        Employment: "NA",
        FormalEducation: "NA",
        UndergradMajor: nil,
        CompanySize: "NA",
        DevType: "NA",
        YearsCoding: "NA",
        YearsCodingProf: nil,
        JobSatisfaction: nil,
        CareerSatisfaction: nil,
        HopeFiveYears: nil,
        JobSearchStatus: nil,
        LastNewJob: nil,
        AssessJob1: nil,
        AssessJob2: nil,
        AssessJob3: nil,
        AssessJob4: nil,
        AssessJob5: nil,
        AssessJob6: nil,
        AssessJob7: nil,
        AssessJob8: nil,
        AssessJob9: nil,
        AssessJob10: nil,
        AssessBenefits1: nil,
        AssessBenefits2: nil,
        AssessBenefits3: nil,
        AssessBenefits4: nil,
        AssessBenefits5: nil,
        AssessBenefits6: nil,
        AssessBenefits7: nil,
        AssessBenefits8: nil,
        AssessBenefits9: nil,
        AssessBenefits10: nil,
        AssessBenefits11: nil,
        JobContactPriorities1: nil,
        JobContactPriorities2: nil,
        JobContactPriorities3: nil,
        JobContactPriorities4: nil,
        JobContactPriorities5: nil,
        JobEmailPriorities1: nil,
        JobEmailPriorities2: nil,
        JobEmailPriorities3: nil,
        JobEmailPriorities4: nil,
        JobEmailPriorities5: nil,
        JobEmailPriorities6: nil,
        JobEmailPriorities7: nil,
        UpdateCV: nil,
        Currency: nil,
        Salary: nil,
        SalaryType: nil,
        ConvertedSalary: nil,
        CurrencySymbol: nil,
        CommunicationTools: nil,
        TimeFullyProductive: nil,
        EducationTypes: nil,
        SelfTaughtTypes: nil,
        TimeAfterBootcamp: nil,
        HackathonReasons: nil,
        AgreeDisagree1: nil,
        AgreeDisagree2: nil,
        AgreeDisagree3: nil,
        LanguageWorkedWith: nil,
        LanguageDesireNextYear: nil,
        DatabaseWorkedWith: nil,
        DatabaseDesireNextYear: nil,
        PlatformWorkedWith: nil,
        PlatformDesireNextYear: nil,
        FrameworkWorkedWith: nil,
        FrameworkDesireNextYear: nil,
        IDE: nil,
        OperatingSystem: nil,
        NumberMonitors: nil,
        Methodology: nil,
        VersionControl: nil,
        CheckInCode: nil,
        AdBlocker: nil,
        AdBlockerDisable: nil,
        AdBlockerReasons: nil,
        AdsAgreeDisagree1: nil,
        AdsAgreeDisagree2: nil,
        AdsAgreeDisagree3: nil,
        AdsActions: nil,
        AdsPriorities1: nil,
        AdsPriorities2: nil,
        AdsPriorities3: nil,
        AdsPriorities4: nil,
        AdsPriorities5: nil,
        AdsPriorities6: nil,
        AdsPriorities7: nil,
        AIDangerous: nil,
        AIInteresting: nil,
        AIResponsible: nil,
        AIFuture: nil,
        EthicsChoice: nil,
        EthicsReport: nil,
        EthicsResponsible: nil,
        EthicalImplications: nil,
        StackOverflowRecommend: nil,
        StackOverflowVisit: nil,
        StackOverflowHasAccount: nil,
        StackOverflowParticipate: nil,
        StackOverflowJobs: nil,
        StackOverflowDevStory: nil,
        StackOverflowJobsRecommend: nil,
        StackOverflowConsiderMember: nil,
        HypotheticalTools1: nil,
        HypotheticalTools2: nil,
        HypotheticalTools3: nil,
        HypotheticalTools4: nil,
        HypotheticalTools5: nil,
        WakeTime: nil,
        HoursComputer: nil,
        HoursOutside: nil,
        SkipMeals: nil,
        ErgonomicDevices: nil,
        Exercise: nil,
        Gender: nil,
        SexualOrientation: nil,
        EducationParents: nil,
        RaceEthnicity: nil,
        Age: nil,
        Dependents: nil,
        MilitaryUS: nil,
        SurveyTooLong: nil,
        SurveyEasy: "NA"
    )
}
