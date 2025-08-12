enum TestResultCases { testNotDone, testFailed, testSucceded }

//to test modifying testNotDone to testNotDoneYet (simbol modify) to see what happens due to the hardcoding I used in shared preferences
//I could move this list to BaseButton class and make it static, but to do later
List<TestResultCases> testData = List.filled(3, TestResultCases.testNotDone);

/*
List<TestResultCases> testData = [
  TestResultCases.testNotDone,
  TestResultCases.testNotDone,
  TestResultCases.testNotDone,
];
*/
