# FormsMaterializedItem
This Oracle Forms PoC demo shows simple materialized handlings of Forms items with native PL/SQL Low-Code.


### Solution includes 4 parts:
* Materializing of non-database table Forms items with 3 additional items for labeling, underlining and messaging
* shows a simple verification of Oracle password inputs
* completion check of all defined items
* demonstrates a automatic Forms item test sequence with comparizion of result states and values

## Getting Started

This modernization of Forms items with materialized item handlings is shown here:
<img src="http://www.fmatz.com/MITEM.gif" />

### Prerequisites

* Oracle Forms 12.2.1.3

### Setup and Deployment

* Download the Forms module **poc_account2.fmb**
* Compile and deploy the Form.

### Programming

* Item definitions in the Forms module:

<img src="http://www.fmatz.com/MITEM-FULL.png" />

* Initializing the Forms items in Users's **prc_Set_Items** procedure:

    ```sql
    PROCEDURE prc_Set_Items IS
    -- User's item value definitions --
    BEGIN
        -- place your item definitions here . ! --
        pkg_Item.prc_rec(1 , 
                        'BLOCK_NAME',
                        'ITEM_NAME',
                        'LABEL_TEXT',
                        'ITEM_TEXT',
                        'ERROR_TEXT',
                        'NOTNULL',    -- { DEFAULT:'YES' | 'NO }
                        'TYPE'        -- { DEFAULT:'NORMAL' | 'SECURE' }
                        );
        ..
    EXCEPTION WHEN OTHERS THEN
        prc_info('$$$ EXCEPTION prc_Set_Items: '||sqlerrm);
    END prc_Set_Items;

    Example:
        pkg_Item.prc_rec(1 , 'BLK_ACCOUNT', 'USERNAME', 'User name',
                            'Enter your user name',    'Must begin with .. followed .. #_$');
    ```

* Every value item must have following two triggers & code:

    ```sql
        -- WEHN-NEW-ITEM-INSTANCE trigger --
        BEGIN
        pkg_item.prc_Enter;
        END W_N_I_INSTANCE;

        -- WHEN-VALIDATE-ITEM trigger --
        BEGIN
        pkg_item.prc_Leave;
        END W_V_ITEM;
    ```

* Verification of Oracle password inputs:

    ```sql
        FUNCTION v#r#fy_pw$001  (
            p_username      varchar2,
            p_password      varchar2
        ) RETURN VARCHAR2 IS
        /*
        * This password check allows some special characters using with "my :-} password.§$"
        * and get the password strength in Oracle Forms for Oracle DB password settings.
        * Remember that you can use ANY characters in Oracle DB
        * enclosed in double quotes e.g. " . - # ~ 12 ..".
        * RETURN: substr(v#r#fy_pw$001,1,3)<>'$$$' => {LIGHT|MEDIUM|STRONG} :: 'OK'
        *         substr(v#r#fy_pw$001,1,3)= '$$$' => '$$$ Error .. $$$' .
        */
    ```
* Final completion check of all defined items, e.g. in **KEY-EXIT** trigger:

    ```sql
        DECLARE
            l_res VARCHAR2(256);
        BEGIN
            l_res:= pkg_Item.fnc_final_check;
            IF l_res<>'OK' THEN
                IF fnc_msg_query('$$$ User uccount is not completed ! $$$'||chr(10)||
                                 l_res ||chr(10)||
                                 'Do you want to exit ?')='YES' THEN
                    Exit_Form(NO_VALIDATE);
                ELSE
                    Raise Form_trigger_Failure;
                END IF;
        END IF;
    ```

## Running the tests

* Automatic test sequence: On item "close" right mouse click and "check all" 
* single tests with own inputs.

## Not implemented

* A generic handling of item objects or visual properties is not implemented yet.
* This materialized item solution here works only for Forms non-database table items.
