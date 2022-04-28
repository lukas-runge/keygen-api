@api/v1.1
Feature: Release artifacts relationship

  Background:
    Given the following "accounts" exist:
      | name    | slug  |
      | Test 1  | test1 |
      | Test 2  | test2 |
    And I send and accept JSON

  Scenario: List endpoint should be inaccessible when account is disabled
    Given the account "test1" is canceled
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "release"
    And the first "release" has an artifact that is uploaded
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "403"

  Scenario: Download endpoint should be inaccessible when account is disabled
    Given the account "test1" is canceled
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "release"
    And the first "release" has an artifact that is uploaded
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  # List artifacts
  Scenario: Admin retrieves the artifacts for a release
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is uploaded
    And the second "release" has an artifact that is uploaded
    And the third "release" has an artifact that is nil
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "200"
    And the JSON response should be an array with 1 "artifact"

  Scenario: Product retrieves the artifacts for a release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the second "release" has an artifact that is uploaded
    And the third "release" has an artifact that is nil
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "200"
    And the JSON response should be an array with 1 "artifact"

  Scenario: Product retrieves the artifacts for a release of another product
    Given the current account is "test1"
    And the current account has 2 "products"
    And the current account has 3 "releases" for the second "product"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "404"

  Scenario: License attempts to retrieve the artifacts for a release of a different product
    Given the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is uploaded
    And the second "release" has an artifact that is uploaded
    And the third "release" has an artifact that is nil
    And the current account has 1 "license"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "404"

  Scenario: License attempts to retrieve the artifacts for a release of their product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 3 "releases" for the first "product"
    And the current account has 1 "policy" for the first "product"
    And the current account has 1 "license" for the first "policy"
    And the first "release" has an artifact that is uploaded
    And the second "release" has an artifact that is uploaded
    And the third "release" has an artifact that is nil
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "200"
    And the JSON response should be an array with 1 "artifact"

  Scenario: User attempts to retrieve the artifacts for a release they don't have a license for
    Given the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is uploaded
    And the second "release" has an artifact that is uploaded
    And the third "release" has an artifact that is nil
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "404"

  Scenario: User attempts to retrieve the artifacts for a release they do have a license for
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 3 "releases" for the first "product"
    And the current account has 1 "policy" for the first "product"
    And the current account has 1 "license" for the first "policy"
    And the first "release" has an artifact that is uploaded
    And the second "release" has an artifact that is uploaded
    And the third "release" has an artifact that is nil
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "200"
    And the JSON response should be an array with 1 "artifact"

  Scenario: Admin attempts to retrieve the artifacts for a release of another account
    Given I am an admin of account "test2"
    And the current account is "test1"
    And the current account has 1 "release"
    And the first "release" has an artifact that is uploaded
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts"
    Then the response status should be "401"

  # Download artifact
  Scenario: Admin retrieves the artifact for a release
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is uploaded
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

   Scenario: Admin retrieves the artifact for a release (1 hour TTL)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is uploaded
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0?ttl=3600"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: Admin retrieves the artifact for a release (10 second TTL)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is uploaded
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0?ttl=10"
    Then the response status should be "400"
    And the first error should have the following properties:
      """
      {
        "title": "Bad request",
        "detail": "must be greater than or equal to 60 (1 minute)",
        "source": {
          "parameter": "ttl"
        }
      }
      """

  Scenario: Admin retrieves the artifact for a release (2 week TTL)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is uploaded
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0?ttl=1209600"
    Then the response status should be "400"
    And the first error should have the following properties:
      """
      {
        "title": "Bad request",
        "detail": "must be less than or equal to 604800 (1 week)",
        "source": {
          "parameter": "ttl"
        }
      }
      """

  Scenario: Admin retrieves the artifact for a release that has not been uploaded
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is not uploaded
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"
    And the first error should have the following properties:
      """
      {
        "title": "Not found",
        "detail": "artifact is unavailable (ensure it has been fully uploaded)",
        "code": "NOT_FOUND"
      }
      """

  Scenario: Admin retrieves the artifact for a release that has been yanked
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "releases"
    And the first "release" has an artifact that is not uploaded
    And the first "release" has the following attributes:
      """
      { "yankedAt": "$time.now" }
      """
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable entity",
        "detail": "has been yanked"
      }
      """

  Scenario: Product retrieves the artifact for a release of their product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    Given I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: Product retrieves the artifact for a release of their product (1 week TTL)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    Given I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0?ttl=604800"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: Product retrieves the artifact for a release of a different product
    Given the current account is "test1"
    And the current account has 2 "products"
    And the current account has 2 "releases" for the second "product"
    And the first "release" has an artifact that is uploaded
    Given I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: License retrieves the artifact for a release of their product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: License retrieves the artifact for a release of their product (1 day TTL)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0?ttl=86400"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: License retrieves the artifact for a release of their product (expired)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.minutes.ago" }
      """
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: License retrieves the artifact for a release of their product (expired after release, restrict access)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the first "policy" has the following attributes:
      """
      { "expirationStrategy": "RESTRICT_ACCESS" }
      """
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.months.ago" }
      """
    And the current account has 3 "releases" for the first "product"
    And the first "release" has the following attributes:
      """
      { "createdAt": "$time.3.months.ago" }
      """
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: License retrieves the artifact for a release of their product (expired after release, revoke access)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the first "policy" has the following attributes:
      """
      { "expirationStrategy": "REVOKE_ACCESS" }
      """
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.months.ago" }
      """
    And the current account has 3 "releases" for the first "product"
    And the first "release" has the following attributes:
      """
      { "createdAt": "$time.3.months.ago" }
      """
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: License retrieves the artifact for a release of their product (suspended)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "suspended": true }
      """
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: License retrieves the artifact for a release of their product (key auth, expired)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the first "policy" has the following attributes:
      """
      {
        "expirationStrategy": "RESTRICT_ACCESS",
        "authenticationStrategy": "LICENSE"
      }
      """
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.minutes.ago" }
      """
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I authenticate with my license key
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: License retrieves the artifact for a release of their product (key auth, expired after release, restrict access)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the first "policy" has the following attributes:
      """
      {
        "expirationStrategy": "RESTRICT_ACCESS",
        "authenticationStrategy": "LICENSE"
      }
      """
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.months.ago" }
      """
    And the current account has 3 "releases" for the first "product"
    And the first "release" has the following attributes:
      """
      { "createdAt": "$time.3.months.ago" }
      """
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I authenticate with my license key
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: License retrieves the artifact for a release of their product (key auth, expired after release, revoke access)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the first "policy" has the following attributes:
      """
      {
        "expirationStrategy": "REVOKE_ACCESS",
        "authenticationStrategy": "LICENSE"
      }
      """
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.months.ago" }
      """
    And the current account has 3 "releases" for the first "product"
    And the first "release" has the following attributes:
      """
      { "createdAt": "$time.3.months.ago" }
      """
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I authenticate with my license key
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: License retrieves the artifact for a release of their product (key auth, suspended)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the first "policy" has the following attributes:
      """
      { "authenticationStrategy": "LICENSE" }
      """
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "suspended": true }
      """
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I authenticate with my license key
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: License retrieves the artifact for a release of a different product
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "license"
    And the current account has 3 "releases" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: License retrieves a release artifact of their product (has single entitlement)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "entitlement"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "license-entitlement" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "licenseId": "$licenses[0]"
      }
      """
    And the current account has 1 "release" for an existing "product"
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "releaseId": "$releases[0]"
      }
      """
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: License retrieves a release artifact of their product (has multiple entitlements)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 2 "entitlements"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "license-entitlement" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "licenseId": "$licenses[0]"
      }
      """
    And the current account has 1 "license-entitlement" with the following:
      """
      {
        "entitlementId": "$entitlements[1]",
        "licenseId": "$licenses[0]"
      }
      """
    And the current account has 1 "release" for an existing "product"
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "releaseId": "$releases[0]"
      }
      """
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[1]",
        "releaseId": "$releases[0]"
      }
      """
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: License retrieves a release artifact of their product (missing some entitlements)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 2 "entitlements"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "license-entitlement" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "licenseId": "$licenses[0]"
      }
      """
    And the current account has 1 "release" for an existing "product"
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "releaseId": "$releases[0]"
      }
      """
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[1]",
        "releaseId": "$releases[0]"
      }
      """
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: License retrieves a release artifact of their product (missing all entitlements)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "release" for an existing "product"
    And the current account has 1 "release-entitlement-constraint" for an existing "release"
    And the first "release" has an artifact that is uploaded
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: User retrieves a release artifact with a license for it
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "release" for an existing "product"
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: User retrieves a release artifact with a license for it (2 minute TTL)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "release" for an existing "product"
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0?ttl=120"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: User retrieves a release artifact with a license for it (expired)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.days.ago" }
      """
    And the current account has 1 "release" for an existing "product"
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: User retrieves a release artifact with a license for it (expired after release)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.days.ago" }
      """
    And the current account has 1 "release" for an existing "product"
    And the first "release" has the following attributes:
      """
      { "createdAt": "$time.1.months.ago" }
      """
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And the JSON response should be an "artifact"

  Scenario: User retrieves a release artifact with a license for it (suspended)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "suspended": true }
      """
    And the current account has 1 "release" for an existing "product"
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: User retrieves a release artifact with multiple licenses for it (expired and non-expired)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 2 "licenses" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.days.ago" }
      """
    And the current account has 1 "release" for an existing "product"
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 2 "licenses"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: User retrieves a release artifact with multiple licenses for it (suspended, expired and valid)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 3 "licenses" for an existing "policy"
    And the first "license" has the following attributes:
      """
      { "expiry": "$time.2.days.ago" }
      """
    And the second "license" has the following attributes:
      """
      { "suspended": true }
      """
    And the current account has 1 "release" for an existing "product"
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 3 "licenses"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: User retrieves a release artifact with a license for it (has single entitlement)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "entitlement"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "license-entitlement" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "licenseId": "$licenses[0]"
      }
      """
    And the current account has 1 "release" for an existing "product"
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "releaseId": "$releases[0]"
      }
      """
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: User retrieves a release artifact with a license for it (has multiple entitlements)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 2 "entitlements"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "license-entitlement" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "licenseId": "$licenses[0]"
      }
      """
    And the current account has 1 "license-entitlement" with the following:
      """
      {
        "entitlementId": "$entitlements[1]",
        "licenseId": "$licenses[0]"
      }
      """
    And the current account has 1 "release" for an existing "product"
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "releaseId": "$releases[0]"
      }
      """
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[1]",
        "releaseId": "$releases[0]"
      }
      """
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: User retrieves a release artifact with a license for it (missing some entitlements)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 2 "entitlements"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "license-entitlement" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "licenseId": "$licenses[0]"
      }
      """
    And the current account has 1 "release" for an existing "product"
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[0]",
        "releaseId": "$releases[0]"
      }
      """
    And the current account has 1 "release-entitlement-constraint" with the following:
      """
      {
        "entitlementId": "$entitlements[1]",
        "releaseId": "$releases[0]"
      }
      """
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: User retrieves a release artifact with a license for it (missing all entitlements)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "release" for an existing "product"
    And the current account has 1 "release-entitlement-constraint" for an existing "release"
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "403"

  Scenario: User retrieves a release artifact without a license for it
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "release"
    And the first "release" has an artifact that is uploaded
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  # Licensed distribution strategy
  Scenario: Anonymous retrieves a LICENSED release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "LICENSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: License retrieves a LICENSED release without a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "LICENSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "license"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: License retrieves a LICENSED release with a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "LICENSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "policy" for the first "product"
    And the current account has 1 "license" for the first "policy"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: User retrieves a LICENSED release without a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "LICENSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "license"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: User retrieves a LICENSED release with a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "LICENSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "policy" for the first "product"
    And the current account has 1 "license" for the first "policy"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: Product retrieves a LICENSED release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "LICENSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: Product retrieves a LICENSED release of another product
    Given the current account is "test1"
    And the current account has 2 "products"
    And the second "product" has the following attributes:
      """
      { "distributionStrategy": "LICENSED" }
      """
    And the current account has 1 "release" for the second "product"
    And the first "release" has an artifact that is uploaded
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: Admin retrieves a LICENSED release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "LICENSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am an admin of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  # Open distribution strategy
  Scenario: Anonymous retrieves an OPEN release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: Anonymous retrieves an OPEN release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: License retrieves an OPEN release without a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "license"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: License retrieves an OPEN release with a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "policy" for the first "product"
    And the current account has 1 "license" for the first "policy"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: User retrieves an OPEN release without a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "license"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: User retrieves an OPEN release with a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "policy" for the first "product"
    And the current account has 1 "license" for the first "policy"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: Product retrieves an OPEN release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: Product retrieves an OPEN release of another product
    Given the current account is "test1"
    And the current account has 2 "products"
    And the second "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the second "product"
    And the first "release" has an artifact that is uploaded
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: Admin retrieves an OPEN release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "OPEN" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am an admin of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  # Closed distribution strategy
  Scenario: Anonymous retrieves a CLOSED release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "CLOSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: License retrieves a CLOSED release without a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "CLOSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "license"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: License retrieves a CLOSED release with a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "CLOSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "policy" for the first "product"
    And the current account has 1 "license" for the first "policy"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: User retrieves a CLOSED release without a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "CLOSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "license"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: User retrieves a CLOSED release with a license for it
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "CLOSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the current account has 1 "policy" for the first "product"
    And the current account has 1 "license" for the first "policy"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    And the current user has 1 "license"
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: Product retrieves a CLOSED release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "CLOSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  Scenario: Product retrieves a CLOSED release of another product
    Given the current account is "test1"
    And the current account has 2 "products"
    And the second "product" has the following attributes:
      """
      { "distributionStrategy": "CLOSED" }
      """
    And the current account has 1 "release" for the second "product"
    And the first "release" has an artifact that is uploaded
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "404"

  Scenario: Admin retrieves a CLOSED release
    Given the current account is "test1"
    And the current account has 1 "product"
    And the first "product" has the following attributes:
      """
      { "distributionStrategy": "CLOSED" }
      """
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And I am an admin of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"

  # Expiration basis
  Scenario: License downloads an artifact with a download expiration basis (not set)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the first "policy" has the following attributes:
      """
      {
        "expirationBasis": "FROM_FIRST_DOWNLOAD",
        "duration": $time.1.year
      }
      """
    And the first "license" has the following attributes:
      """
      {
        "policyId": "$policies[0]",
        "expiry": null
      }
      """
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And sidekiq should process 1 "event-log" job
    And sidekiq should process 1 "event-notification" job
    And the first "license" should have a 1 year expiry

  Scenario: License downloads an artifact with a download expiration basis (set)
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policy" for an existing "product"
    And the current account has 1 "license" for an existing "policy"
    And the current account has 1 "release" for the first "product"
    And the first "release" has an artifact that is uploaded
    And the first "policy" has the following attributes:
      """
      {
        "expirationBasis": "FROM_FIRST_DOWNLOAD",
        "duration": $time.1.year
      }
      """
    And the first "license" has the following attributes:
      """
      {
        "policyId": "$policies[0]",
        "expiry": "2042-01-03T14:18:02.743Z"
      }
      """
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/releases/$0/artifacts/$0"
    Then the response status should be "303"
    And sidekiq should process 1 "event-log" job
    And sidekiq should process 1 "event-notification" job
    And the first "license" should have the expiry "2042-01-03T14:18:02.743Z"
