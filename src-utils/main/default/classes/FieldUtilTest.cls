@isTest
private without sharing class FieldUtilTest {
  @IsTest
  private static void testSingleField() {
    String field = 'Description';

    Test.startTest();

    Map<String, Schema.DescribeFieldResult> result = FieldUtil.getDescribeByField(
      'Account',
      new Set<String>{ field },
      true
    );

    Test.stopTest();

    Assert.isNotNull(result.get('Description'));
  }

  @IsTest
  private static void testRelationshipField() {
    String field = 'Account.Owner.Name';

    Test.startTest();

    Map<String, Schema.DescribeFieldResult> result = FieldUtil.getDescribeByField(
      'Contact',
      new Set<String>{ field },
      true
    );

    Test.stopTest();

    Assert.isNotNull(result.get(field));
  }

  @IsTest
  private static void testMultipleFields() {
    Set<String> fields = new Set<String>{
      'Account.Owner.Name',
      'Account.OwnerId',
      'Name',
      'OwnerId'
    };

    Test.startTest();

    Map<String, Schema.DescribeFieldResult> result = FieldUtil.getDescribeByField(
      'Contact',
      fields,
      true
    );

    Test.stopTest();

    for (String field : fields) {
      Assert.isNotNull(result.get(field));
    }
  }

  @IsTest
  private static void shouldIgnoreFieldWhenAllOrNoneIsFalse() {
    List<String> fields = new List<String>{ 'Account.Name', 'aslkdfjalskd' };

    Test.startTest();

    Map<String, Schema.DescribeFieldResult> result = FieldUtil.getDescribeByField(
      'Contact',
      new Set<String>(fields),
      false
    );

    Test.stopTest();

    Assert.isNotNull(result.get(fields[0]));
    Assert.isNull(result.get(fields[1]));
  }

  @IsTest
  private static void shouldThrowExceptionWhenAllOrNoneIsTrue() {
    List<String> fields = new List<String>{ 'Account.Name', 'aslkdfjalskd' };

    Boolean failed = false;
    Test.startTest();

    try {
      Map<String, Schema.DescribeFieldResult> result = FieldUtil.getDescribeByField(
        'Contact',
        new Set<String>(fields),
        true
      );
    } catch (Exception e) {
      failed = true;
    }

    Test.stopTest();

    Assert.isTrue(failed);
  }
}
