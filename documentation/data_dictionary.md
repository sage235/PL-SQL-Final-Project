# 📘 DATA DICTIONARY  
### Transport & Fleet Management System  
**Project:** MON_27232_LESAGE_TRANSPORT_DB  
**Author:** Mr Sage (ID: 27232)

---

## 🔹 TABLE: USERS
| Column        | Type           | Constraints                        | Purpose |
|---------------|----------------|-------------------------------------|---------|
| USER_ID       | NUMBER         | PK, GENERATED ALWAYS AS IDENTITY   | Unique user |
| USERNAME      | VARCHAR2(50)   | UNIQUE, NOT NULL                   | Login name |
| FULL_NAME     | VARCHAR2(200)  | NOT NULL                           | Employee full name |
| ROLE          | VARCHAR2(50)   | CHECK(role IN ('ADMIN','EMPLOYEE'))| User role |
| EMAIL         | VARCHAR2(200)  | UNIQUE                             | Contact email |
| CREATED_AT    | TIMESTAMP      | DEFAULT SYSTIMESTAMP               | Creation date |

---

## 🔹 TABLE: VEHICLES
| Column        | Type           | Constraints                        | Purpose |
|---------------|----------------|-------------------------------------|---------|
| VEHICLE_ID    | NUMBER         | PK, IDENTITY                       | Unique vehicle |
| VEHICLE_TYPE  | VARCHAR2(50)   | NOT NULL                           | Truck/Bus/Car |
| MODEL         | VARCHAR2(100)  | NOT NULL                           | Model name |
| YEAR_MADE     | NUMBER(4)      | CHECK(year_made > 1980)            | Manufacturing year |
| STATUS        | VARCHAR2(20)   | DEFAULT 'ACTIVE'                   | ACTIVE / MAINTENANCE |

---

## 🔹 TABLE: DRIVERS
| Column        | Type           | Constraints                        | Purpose |
|---------------|----------------|-------------------------------------|---------|
| DRIVER_ID     | NUMBER         | PK, IDENTITY                       | Unique driver |
| FULL_NAME     | VARCHAR2(200)  | NOT NULL                           | Driver name |
| LICENSE_NO    | VARCHAR2(50)   | UNIQUE NOT NULL                    | Driving license |
| PHONE         | VARCHAR2(20)   | NULL                               | Contact number |

---

## 🔹 TABLE: ROUTES
| Column        | Type          | Constraints      | Purpose |
|----------------|---------------|------------------|---------|
| ROUTE_ID      | NUMBER        | PK, IDENTITY     | Unique route |
| START_CITY    | VARCHAR2(100) | NOT NULL         | Starting point |
| END_CITY      | VARCHAR2(100) | NOT NULL         | Destination |
| DISTANCE_KM   | NUMBER        | NOT NULL         | Route distance |

---

## 🔹 TABLE: TRIPS
| Column        | Type      | Constraints                             | Purpose |
|---------------|-----------|-------------------------------------------|---------|
| TRIP_ID       | NUMBER    | PK, IDENTITY                             | Trip unique ID |
| VEHICLE_ID    | NUMBER    | FK → VEHICLES(VEHICLE_ID) NOT NULL       | Assigned vehicle |
| DRIVER_ID     | NUMBER    | FK → DRIVERS(DRIVER_ID) NOT NULL         | Assigned driver |
| ROUTE_ID      | NUMBER    | FK → ROUTES(ROUTE_ID) NOT NULL           | Trip route |
| TRIP_DATE     | DATE      | NOT NULL                                 | Date of trip |
| STATUS        | VARCHAR2(20) | DEFAULT 'SCHEDULED'                    | SCHEDULED / COMPLETED |

---

## 🔹 TABLE: PARTS
| Column        | Type      | Constraints                    | Purpose |
|---------------|-----------|----------------------------------|---------|
| PART_ID       | NUMBER    | PK, IDENTITY                    | Unique part |
| PART_NAME     | VARCHAR2(100) | NOT NULL                   | Spare part name |
| UNIT_PRICE    | NUMBER(10,2) | CHECK(unit_price ≥ 0)       | Cost of item |
| STOCK_QTY     | NUMBER      | CHECK(stock_qty ≥ 0)         | Quantity available |

---

## 🔹 TABLE: MAINTENANCE_RECORDS
| Column          | Type       | Constraints                                   | Purpose |
|-----------------|------------|-----------------------------------------------|---------|
| MAINT_ID        | NUMBER     | PK, IDENTITY                                   | Maintenance ID |
| VEHICLE_ID      | NUMBER     | FK → VEHICLES                                  | Vehicle serviced |
| DESCRIPTION     | VARCHAR2(200) | NOT NULL                                   | Work description |
| COST            | NUMBER(10,2) | CHECK(cost >= 0)                             | Cost |
| STATUS          | VARCHAR2(50) | CHECK(status IN ('PENDING','DONE','OVERDUE'))| Maintenance status |
| SCHEDULED_DATE  | DATE       | NOT NULL                                       | Planned date |
| COMPLETED_DATE  | DATE       | NULL                                           | When completed |

---

## 🔹 TABLE: MAINTENANCE_PARTS (Bridge Table)
| Column          | Type       | Constraints                                   | Purpose |
|-----------------|------------|-----------------------------------------------|---------|
| MAINT_ID        | NUMBER     | FK → MAINTENANCE_RECORDS                      | Relation |
| PART_ID         | NUMBER     | FK → PARTS                                    | Relation |
| QUANTITY_USED   | NUMBER     | CHECK(quantity_used > 0)                      | Amount used |
| **PK(MAINT_ID, PART_ID)** | | Composite PK |

---

## 🔹 TABLE: ALERTS
| Column       | Type        | Constraints          | Purpose |
|--------------|-------------|----------------------|---------|
| ALERT_ID     | NUMBER      | PK, IDENTITY         | Unique alert |
| ALERT_TYPE   | VARCHAR2(100) | NOT NULL          | e.g., OVERDUE |
| ENTITY_ID    | NUMBER      | NOT NULL            | Related row |
| MESSAGE      | VARCHAR2(400) | NOT NULL          | Human message |
| CREATED_AT   | TIMESTAMP   | DEFAULT SYSTIMESTAMP | Time inserted |

---

## 🔹 TABLE: AUDIT_LOG / AUDIT_DML_LOG
| Column       | Type        | Constraints          | Purpose |
|--------------|-------------|----------------------|---------|
| AUDIT_ID     | NUMBER      | PK, IDENTITY         | Entry ID |
| EVENT_TS     | TIMESTAMP   | DEFAULT SYSTIMESTAMP | Time |
| USERNAME     | VARCHAR2(100) | NOT NULL          | Who performed action |
| USER_ROLE    | VARCHAR2(50) | NOT NULL           | ADMIN / EMPLOYEE |
| OPERATION    | VARCHAR2(20) | NOT NULL           | INSERT/UPDATE/DELETE |
| OBJECT_NAME  | VARCHAR2(50) | NOT NULL           | Table name |
| ROW_ID_TEXT  | VARCHAR2(200) | NULL              | Row reference |
| ALLOWED_FLG  | CHAR(1)     | 'Y'/'N'             | Allowed? |
| REASON       | VARCHAR2(200) | NULL              | Reason for block |

