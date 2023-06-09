public with sharing class FieldUtil {
  public static Map<String, Schema.DescribeFieldResult> getDescribeByField(
    String objectName,
    Set<String> fields,
    Boolean allOrNone
  ) {
    String objectApiName = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .getName();

    Map<String, Schema.DescribeFieldResult> result = new Map<String, Schema.DescribeFieldResult>();

    for (String fieldApiName : fields) {
      try {
        Schema.DescribeFieldResult singleResult = !fieldApiName.contains('.')
          ? FieldUtility.getFieldDescribe(objectApiName, fieldApiName)
          : getFieldDescribeFromRelationshipField(fieldApiName, objectApiName);
        result.put(fieldApiName, singleResult);
      } catch (Exception e) {
        if (allOrNone) {
          throw new FieldUtilException(e.getMessage());
        }
      }
    }

    return result;
  }

  private static Schema.DescribeFieldResult getFieldDescribeFromRelationshipField(
    String relationship,
    String objectName
  ) {
    relationship = relationship.toUpperCase();
    List<String> fields = relationship.split('\\.');
    // remove the last field because that is the actual field
    String actualField = fields.remove(fields.size() - 1);

    for (String relationshipField : fields) {
      Map<String, Schema.SObjectField> mapOfDescribes = Schema.getGlobalDescribe()
        .get(objectName)
        .getDescribe()
        .fields
        .getMap();

      for (Schema.SObjectField field : mapOfDescribes.values()) {
        Schema.DescribeFieldResult describe = field.getDescribe();

        if (
          describe.getType() == Schema.DisplayType.REFERENCE &&
          describe.getRelationshipName().toUpperCase() == relationshipField
        ) {
          objectName = describe.getReferenceto()[0].getDescribe().getName();
          // finalRelationShip.add(describe.getRelationshipName());
          break;
        }
      }
    }

    // add the last field to be
    // finalRelationShip.add(describe.getName());
    // String fullApiName = String.join(finalRelationShip, '.');

    return FieldUtility.getFieldDescribe(objectName, actualField);
  }

  // private class RelationShipFieldDescribe {
  //   private String fullApiName;
  //   private DescribeFieldResult describe;

  //   private RelationShipFieldDescribe(
  //     String fullApiName,
  //     DescribeFieldResult describe
  //   ) {
  //     this.fullApiName = fullApiName;
  //     this.describe = describe;
  //   }
  // }

  private class FieldUtilException extends Exception {
  }
}
