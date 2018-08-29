User API V1
===========
User API is client-to-server API

**Version:** 0.0.1

### /v1/beneficiaries/{rid}
---
##### ***DELETE***
**Description:** Delete a beneficiary

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| rid | path |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 204 | Succefully deleted |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Beneficiary is not found |

##### ***PATCH***
**Description:** Updates a beneficiary

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| rid | path |  | Yes | string |
| full_name | formData |  | No | string |
| address | formData |  | No | string |
| country | formData |  | No | string |
| currency | formData |  | No | string |
| account_number | formData |  | No | string |
| account_type | formData |  | No | string |
| bank_name | formData |  | No | string |
| bank_address | formData |  | No | string |
| bank_country | formData |  | No | string |
| bank_swift_code | formData |  | No | string |
| intermediary_bank_name | formData |  | No | string |
| intermediary_bank_address | formData |  | No | string |
| intermediary_bank_country | formData |  | No | string |
| intermediary_bank_swift_code | formData |  | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Updates a beneficiary |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Beneficiary is not found |
| 422 | Validation errors |

##### ***GET***
**Description:** Return a beneficiary by rid

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| rid | path |  | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | Return a beneficiary by rid |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 404 | Beneficiary is not found |

### /v1/beneficiaries
---
##### ***POST***
**Description:** Create a beneficiary

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| full_name | formData |  | Yes | string |
| address | formData |  | Yes | string |
| country | formData |  | Yes | string |
| currency | formData |  | Yes | string |
| account_number | formData |  | Yes | string |
| account_type | formData |  | Yes | string |
| bank_name | formData |  | Yes | string |
| bank_address | formData |  | Yes | string |
| bank_country | formData |  | Yes | string |
| bank_swift_code | formData |  | No | string |
| intermediary_bank_name | formData |  | No | string |
| intermediary_bank_address | formData |  | No | string |
| intermediary_bank_country | formData |  | No | string |
| intermediary_bank_swift_code | formData |  | No | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Create a beneficiary |
| 400 | Required params are empty |
| 401 | Invalid bearer token |
| 422 | Validation errors |

##### ***GET***
**Description:** List all beneficiaries for current account.

**Responses**

| Code | Description |
| ---- | ----------- |
| 200 | List all beneficiaries for current account. |
| 401 | Invalid bearer token |

### /v1/withdraws
---
##### ***POST***
**Description:** Request a withdraw

**Parameters**

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ---- |
| currency | formData | Any supported currency: USD, BTC, ETH. | Yes | string |
| amount | formData | Withdraw amount. | Yes | double |
| otp | formData | Two-factor authentication code | Yes | string |
| rid | formData | The beneficiary ID or wallet address on the Blockchain. | Yes | string |
| currency_type | formData | Type of currency: fiat or coin | Yes | string |

**Responses**

| Code | Description |
| ---- | ----------- |
| 201 | Request a withdraw |
