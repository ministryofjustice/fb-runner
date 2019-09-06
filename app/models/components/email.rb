module Components
  class Email < Component
    def to_hash
      {
        "_id": id,
        "_type": "email",
        "errors": {
          "required": {
            "inline": "Enter the solicitor's email address",
            "summary": "Enter the solicitor's email address"
          }
        },
        "hint": "<p>We’ll use this to send you a copy of your application, and to contact you with a decision</p>",
        "label": "Email address",
        "name": "solicitor_email",
        "$component": true,
        "$control": true,
        "$definition": true,
        "$field": true,
        "$namespaceUpdated": true,
        "_idsuffix": "",
        "$instanceNamespace": "",
        "disabled": false,
        "show": true,
        "namespaceProtect": false,
        "repeatableMinimum": 1
      }
    end
  end
end
