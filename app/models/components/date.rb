module Components
  class Date < Component
    def to_hash
      {
        "_id": "page.defendant--dob",
        "_type": "date",
        "errors": {
          "required": {
            "inline": "Enter the defendant's date of birth",
            "summary": "Enter the defendant's date of birth"
          }
        },
        "hint": "<p>For example, 31 3 1980</p>",
        "label": "Date of birth",
        "name": "COMPOSITE.dob",
        "$component": true,
        "$control": true,
        "$definition": true,
        "$field": true,
        "$namespaceUpdated": true,
        "_idsuffix": "",
        "$instanceNamespace": "",
        "$originalName": "dob",
        "items": [
          {
            "instanceName": "dob",
            "compositeName": "COMPOSITE.dob-day",
            "name": "COMPOSITE.dob-day",
            "label": "Day",
            "classes": "govuk-input--width-2",
            "value": ""
          },
          {
            "instanceName": "dob",
            "compositeName": "COMPOSITE.dob-month",
            "name": "COMPOSITE.dob-month",
            "label": "Month",
            "classes": "govuk-input--width-2",
            "value": ""
          },
          {
            "instanceName": "dob",
            "compositeName": "COMPOSITE.dob-year",
            "name": "COMPOSITE.dob-year",
            "label": "Year",
            "classes": "govuk-input--width-4",
            "value": ""
          }
        ],
        "dateType": "day-month-year",
        "disabled": false,
        "show": true,
        "namespaceProtect": false,
        "repeatableMinimum": 1
      }
    end
  end
end
