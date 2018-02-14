--- [BO-FORM: {FORM-NAME:POC_ACCOUNT_FINAL2}]

--- [BO showFormLevelTriggers]  ---

/*
 * Created by Friedhold.Matz@yahoo.com - Jan-2018
 * It's only a first PoC Demo to demonstrate the simple power of Forms
 * for native modernizing of Forms Items as "Materialized Items" :
 *
 * - Low Native PL/SQL Forms code
 * - using simple four Items for one: 
 *   o LABEL_Item
 *   o Item
 *   o UNDER_Item
 *   o MSG_Item .
 * - D_% items: Not used, only as separators.
 * - demonstrate a low code automated self check of this items.
 * --------------------------------------------------------------
 * NOT's: 
 * ------
 * - no using for production (only at own risk)
 * - no generic solution or object library based
 * - no maintainability
 * - no guarantee.
 *
 */

DECLARE	
	l_timer TIMER;
BEGIN
	
  pkg_Item.prc_Init_Items;
  
  go_item('DUMMY');
   
END W_N_F_I;


BEGIN
	
   IF ERROR_CODE IN (42100) THEN
      NULL;
   ELSE
      prc_info('ERR::'||ERROR_CODE||'/'||ERROR_TEXT);
   END IF;

END ON_ERROR;

BEGIN

   prc_info('ON-MESSAGE::'||MESSAGE_CODE);

END ON_MESSAGE;


BEGIN

   NULL;

END ON_LOGON;

DECLARE
   l_res VARCHAR2(256);
BEGIN
   l_res:= pkg_Item.fnc_final_check;	
   IF l_res<>'OK' THEN
      IF fnc_msg_query('$$$ User uccount is not completed ! $$$'||chr(10)||
		 	l_res ||chr(10)||
		       'Do you want to exit ?')='YES' THEN
	 EXIT_FORM(NO_VALIDATE);
      ELSE
         Raise Form_trigger_Failure;
      END IF;
   END IF;
	
   -- permanent storage function here ... --
   prc_info('User account is completed .');
	
   EXIT_FORM;
	
END KEY_EXIT;

--- [EO showFormLevelTriggers]  ---

--- [BO showBlockLevelTriggers] ---
--- [EO showBlockLevelTriggers] ---

--- [BO showItemLevelTriggers] ---

BEGIN
  pkg_item.prc_Leave;
END W_V_ITEM;

BEGIN
  pkg_item.prc_Enter;
END W_N_I_INSTANCE;

BEGIN	
  pkg_item.prc_Leave;
END W_V_ITEM;

BEGIN	
  pkg_item.prc_Enter;
END W_N_I_INSTANCE;
 
BEGIN	
  pkg_item.prc_Leave;
END W_V_ITEM;

BEGIN	
  pkg_item.prc_Enter;
END W_N_I_INSTANCE;
 
BEGIN	
  pkg_item.prc_Leave;
END W_V_ITEM;

BEGIN	
  pkg_item.prc_Enter;
END W_N_I_INSTANCE;
 
BEGIN	
  pkg_item.prc_Leave;
END W_V_ITEM;

BEGIN	
  pkg_item.prc_Enter;
END W_N_I_INSTANCE;
 
BEGIN	
  pkg_item.prc_Leave;
END W_V_ITEM;

BEGIN	
  pkg_item.prc_Enter;
END W_N_I_INSTANCE;
 
BEGIN	
  pkg_item.prc_Leave;
END W_V_ITEM;

BEGIN	
  pkg_item.prc_Enter;
END W_N_I_INSTANCE;
 
BEGIN	
  pkg_item.prc_Leave;
END W_V_ITEM;

BEGIN	
  pkg_item.prc_Enter;
END W_N_I_INSTANCE;
  
DECLARE
   l_res VARCHAR2(256);
BEGIN	
   SYNCHRONIZE;
	
   l_res:= pkg_Item.fnc_final_check;
   IF l_res='OK' THEN
      prc_info(' User account is completed. ');
   ELSE
      prc_info('$$$ User account is not completed. $$$'||chr(10)||l_res);
   END IF;	
END;

BEGIN
   DO_KEY('EXIT');	  
END;

--- [EO showItemLevelTriggers] ---

--- [BO showProgrammUnits] ---

PACKAGE pkg_Item IS

  -- Friedhold Matz - 2018-FEB
  
  gLastItem VARCHAR2(128);
  
  C_BlockName CONSTANT VARCHAR2(32):= 'BLK_ACCOUNT';
     
  TYPE rec_def_t IS RECORD (id     	NUMBER(4),    
                            block  	VARCHAR2(32),
                            name   	VARCHAR2(32), 
                            label  	VARCHAR2(64), 
                            text 	VARCHAR2(64), 
                            msg 	VARCHAR2(64),
                            notnull     VARCHAR2(8),
                            type   	VARCHAR2(32)
                           );
                           

  TYPE rec_item_name_t IS TABLE OF rec_def_t INDEX BY VARCHAR2(32);	 -- order by code
  TYPE rec_item_ix_t   IS TABLE OF rec_def_t INDEX BY PLS_INTEGER;	 -- order by index

  item_name   rec_item_name_t;  
  item_ix     rec_item_name_t;

-- WHEN-NEW-INSTANCE-ITEM trigger --
PROCEDURE prc_Enter;

-- WHEN-VALIDATE-ITEM trigger --
PROCEDURE prc_Leave;

-- e.g. KEX-EXIT trigger --
FUNCTION fnc_final_check RETURN VARCHAR2;

-- automated checks a item --
PROCEDURE prc_chk_item (p_block VARCHAR2, p_item VARCHAR2, p_value VARCHAR2, p_result VARCHAR2 DEFAULT NULL);

PROCEDURE prc_rec (p_ix PLS_INTEGER, p_block VARCHAR2, p_name VARCHAR2, p_label VARCHAR2, p_text VARCHAR2, 
                   p_messg VARCHAR2 DEFAULT NULL, p_notnull VARCHAR2 DEFAULT 'YES', p_type VARCHAR2 DEFAULT 'NORMAL');

PROCEDURE prc_init_Items;
                
END pkg_Item;
PROCEDURE prc_info(s VARCHAR2) IS
  al_button PLS_INTEGER;
  al_id     Alert;
BEGIN
   -- ${open} --
   al_id:= FIND_ALERT('INFO'); 
   SET_ALERT_PROPERTY(al_id, ALERT_MESSAGE_TEXT, s ); 
   al_button := SHOW_ALERT( al_id ); 
END prc_info;

FUNCTION fnc_validate (p_item VARCHAR2) RETURN VARCHAR2 IS
   l_vres VARCHAR2(256);
BEGIN	
   IF p_item='EMAIL' THEN
      IF regexp_like(:BLK_ACCOUNT.EMAIL, 
		     '([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})')
         THEN
         RETURN('OK');
      ELSE
	 RETURN('$$$ Error: '|| pkg_Item.item_name('EMAIL').msg ||' $$$');
      END IF;
      
   ELSIF p_item='EMAIL2' THEN
      IF LOWER(:BLK_ACCOUNT.EMAIL)=LOWER(:BLK_ACCOUNT.EMAIL2) THEN
	 RETURN('$$$ Error: eMail2 is the same as eMail ! $$$');
      END IF;
      IF regexp_like(:BLK_ACCOUNT.EMAIL2, 
		     '([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})')
	 THEN
         RETURN('OK');
      ELSE
	 RETURN('$$$ Error: '|| pkg_Item.item_name('EMAIL2').msg ||' $$$');
      END IF;
	
    ELSIF p_item='PASSWORD' THEN
	 IF :BLK_ACCOUNT.PASSWORD<>pkg_Item.item_name('PASSWORD').text THEN
	    l_vres:=v#r#fy_pw$001(:BLK_ACCOUNT.USERNAME,:BLK_ACCOUNT.PASSWORD);
	    IF l_vres='OK' THEN
	       RETURN('OK');
	    ELSE
	       RETURN(l_vres);
	    END IF;
         ELSE
	    RETURN('$$$ Error: Username and Password are not completed ! $$$');
         END IF;
	
     ELSIF p_item='PASSWORD_RETRY' THEN
	 IF :PASSWORD<>:PASSWORD_RETRY THEN
	    RETURN('$$$ Error: Passwords are not identical ! $$$');
	 END IF;
     END IF;
	
   RETURN('OK');
	
EXCEPTION WHEN OTHERS THEN
    RETURN('$$$ EXCEPTION in fbc_validate) - item: '||p_item||' : '||sqlerrm);
END;

FUNCTION v#r#fy_pw$001 (	  
        p_username      varchar2,
  	p_password      varchar2
) RETURN VARCHAR2 IS

 /* 
  * This password check enabled some special characters using with "my :-} password.§$"
  * and get the password strength in Oracle Forms for the Oracle DB password setting.
  * That's a maximal password variant; remember that you can use ANY characters
  * in Oracle DB enclosed in double quotes e.g. " . - # ~ 12 .."
  * OUTPUT: substr(v#r#fy_pw$001,1,3)<>'$$$' => {LIGHT|MEDIUM|STRONG} :: 'OK'
  *         substr(v#r#fy_pw$001,1,3)= '$$$' => '$$$ Error .. $$$' .
  * Friedhold Matz - 2017-DEC
  *
 **/
   -- password strength definition --
   C_MINPWLEN    CONSTANT NUMBER(3) :=12;
   C_MINDIGIT    CONSTANT NUMBER(3) :=3;
   C_MINCHARLOW  CONSTANT NUMBER(3) :=3;
   C_MINCHARUPP  CONSTANT NUMBER(3) :=3;
   C_MINSPECIAL  CONSTANT NUMBER(3) :=3;
   C_MEDIUM      CONSTANT NUMBER(2) :=17;
   C_STRONG      CONSTANT NUMBER(2) :=20;
   
   l_lenpw        NUMBER(2);
   l_restype      VARCHAR2(32);
   l_cnt_charlow  NUMBER(3) :=0;
   l_cnt_charupp  NUMBER(3) :=0;
   l_cnt_digit    NUMBER(3) :=0;
   l_cnt_special  NUMBER(3) :=0;
   l_cnt_NO       NUMBER(3) :=0;
   l_1un          CHAR(1);
   l_lenun	  NUMBER(2);
   l_char 	  CHAR(1);

BEGIN 
   -- Check for the minimum length of the password --
   l_lenpw := length(p_password);
   IF l_lenpw < C_MINPWLEN THEN
      RETURN('$$$ Error: Password length less than '||C_MINPWLEN||' characters. $$$');
   END IF;
   -- Check if the password is same as the username or username(1-100)
   IF LOWER(password) = LOWER(p_username) THEN
      RETURN('$$$ Error: Password same as or similar to user $$$');
   END IF;
   l_lenun := length(p_username);
   l_1un   := substr(p_username,1,1);
   ------------------------------------------------------------------------------
   --- Friedhold Matz : 14.10.2013 / 14.12.2017 / 09.02.2018                       ---
   ------------------------------------------------------------------------------
   FOR i IN 1..l_lenpw LOOP 
       l_char := substr(p_password, i ,1);      
       IF l_char BETWEEN 'a' AND 'z' THEN    
          l_cnt_charlow:= l_cnt_charlow+1;
       ELSIF l_char BETWEEN 'A' and 'Z' THEN
      	  l_cnt_charupp:= l_cnt_charupp+1;     	  
       ELSIF l_char BETWEEN '0' AND '9' THEN
          l_cnt_digit:= l_cnt_digit+1;    
       ELSIF l_char IN( '#', '_', '$', '!', '"', '§', '%', '&', '/', '(', ')', '=', '?', '\', '{', '>', '<', '`',  '°',
       	                '[', ']', '}', '~', '+', '*', '#', '-', ';', ',', ':', '.', ':', ' ', '´', ' ', '|', '''', '^' ) THEN
          l_cnt_special:= l_cnt_special+1;         
       ELSE
          l_cnt_NO := l_cnt_NO+1;
       END IF;
       IF LOWER(l_char)=LOWER(l_1un) THEN
       	  IF LOWER(p_username)=LOWER(substr(p_password,i,l_lenun)) THEN
       	  	 RETURN('$$$ Error: Username is included in Password ! $$$');
       	  END IF;
       END IF;
   END LOOP;   
   IF l_cnt_charlow<C_MINCHARLOW THEN
      RETURN('$$$ Error: Password does not incl. min. '||C_MINCHARLOW||' lower case characters. $$$ ');
   END IF;
   IF l_cnt_charupp<C_MINCHARUPP THEN
      RETURN('$$$ Error: Password does not incl. min. '||C_MINCHARUPP||' upper case characters. $$$ ');
   END IF;
   IF l_cnt_digit<C_MINDIGIT THEN
      RETURN('$$$ Error: Password does not incl. min. '||C_MINDIGIT||' digit characters. $$$ ');
   END IF;
   IF l_cnt_special<C_MINSPECIAL THEN
      RETURN('$$$ Error: Password does not incl. min. '||C_MINSPECIAL||' special characters. $$$ ');
   END IF;   
   IF l_cnt_NO>0 THEN
      RETURN('$$$ Error: Password contains invalid characters. $$$');
   END IF;
   ------------------------------------------------------------------------------  
   --- Everything is fine, get the strength now. ---  
   l_restype:='LIGHT';
   IF l_lenpw BETWEEN C_MEDIUM AND C_STRONG THEN
   	  l_restype:='MEDIUM';
   ELSIF l_lenpw > C_STRONG THEN
   	  l_restype:='STRONG';
   END IF;
   
   RETURN (l_restype);

EXCEPTION WHEN OTHERS THEN
   RETURN ('$$$ : '||l_lenpw||' / '||sqlerrm);	
END  v#r#fy_pw$001;

FUNCTION fnc_msg_query(p_msg VARCHAR2) RETURN VARCHAR2 IS
   l_button PLS_INTEGER;
   l_id 		Alert;
   l_res VARCHAR2(32);
BEGIN
   l_id:= FIND_ALERT('QUERY'); 
   SET_ALERT_PROPERTY(l_id, ALERT_MESSAGE_TEXT, p_msg ); 
   l_button := SHOW_ALERT( l_id ); 
   IF l_button = ALERT_BUTTON1 THEN
      l_res := 'YES';
   ELSIF l_button = ALERT_BUTTON2 THEN
      l_res := 'NO';
   ELSE
      l_res := 'CANCEL';
   END IF;
      
   RETURN(l_res);
  
END fnc_msg_query;

PROCEDURE prc_chk_item_sequence IS
   -- Friedhold Matz - 2018-FEB --
   -- Automated self check sequence definition . --
BEGIN
	 --               block          item        			   value              result( DEFAULT:OK | NOK )
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'USERNAME', 				'Tester'         		);
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'FULLNAME', 				'Friedhold Matz' 		);
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'EMAIL',    				'fx@xx.'         	      ,'OK'); -- <<< that's FALSE !
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'EMAIL',    				'fx@xx.com'      		);
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'EMAIL2',    				'fx@xx.com'      	      ,'NOK');
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'EMAIL2',    				'fy@xx.com'      		);
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'QUERY',    				'What''s the name of your cat ?');
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'ANSWER',   				'Susi'           							  );
   
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				'13aaaPPP+#-'                 ,'NOK');
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				'1333aaPPP+#-'                ,'NOK');  
   
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				'testeraaPPP+#-123456'        ,'NOK');
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				'aaPPPtester+#-123456'        ,'NOK');
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				'123aaaPPP+#-1TESTER'         ,'NOK');
  
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				'123aaaPPP+#-'                  );
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				'123aaaPPP+#-123456'            );  
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				'123aaaPPP+#-1234567890'        );
   
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD_RETRY', 	                '123aaaPPP+#-1234567891'        );
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD_RETRY', 	                '123aaaPPP+#-1234567890'        );
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'BT_COMMIT', 		 		'PRESS'                         );
   
   -- clear (reset) items --
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'USERNAME', 				''      );
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'FULLNAME', 				''      );
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'EMAIL',    				''      ); 
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'EMAIL2',    				''      ); 
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'QUERY',    				''      );
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'ANSWER',   				''      );
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD', 				''      );
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'PASSWORD_RETRY', 	                ''      );
   
   pkg_Item.prc_chk_item('BLK_ACCOUNT', 'BT_COMMIT', 				'GO'    );
   
END prc_chk_item_sequence;

PACKAGE BODY pkg_Item IS

-- Friedhold Matz - 2018-FEB
  
-----------------------------------------------------------------------------------
-- private procs / funcs --
-----------------------------------------------------------------------------------
PROCEDURE prc_enable_item (p_item VARCHAR2) IS
BEGIN
   -- display items only ! --
   Set_Item_Property(p_item , VISIBLE, PROPERTY_TRUE); 
   -- Set_Item_Property(p_item , ENABLED, PROPERTY_TRUE);     
END prc_enable_item;
-----------------------------------------------------------------------------------
PROCEDURE sleep (p_x NUMBER) IS
   x NUMBER;
BEGIN
   FOR i IN 1..p_x LOOP
       x:= POWER(2, 100);
       SYNCHRONIZE;
   END LOOP;
END sleep;
-----------------------------------------------------------------------------------
FUNCTION fnc_get_txtnnullc (p_bit VARCHAR2, p_txt VARCHAR2)RETURN VARCHAR2 IS
BEGIN
   IF pkg_Item.item_name(p_bit).notnull='YES' THEN
      RETURN(p_txt||' *');
   ELSE
      RETURN(p_txt);
   END IF;
END fnc_get_txtnnullc;
-----------------------------------------------------------------------------------
FUNCTION fnc_sign_msg (p_txt VARCHAR2) RETURN VARCHAR2 IS
BEGIN
   CASE p_txt 
	WHEN 'LIGHT'  THEN RETURN('VA_TXT_LIGHT_MSG'); 
	WHEN 'MEDIUM' THEN RETURN('VA_TXT_MEDIUM_MSG'); 
	WHEN 'STRONG' THEN RETURN('VA_TXT_STRONG_MSG'); 
   ELSE
	RETURN('VA_TXT_ERROR_MSG');
   END CASE; 
END fnc_sign_msg;
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-- global procs / funcs --
-----------------------------------------------------------------------------------
PROCEDURE prc_Enter IS
   l_blk    VARCHAR2(32);
   l_fit    VARCHAR2(32);
   l_bit    VARCHAR2(32);
BEGIN			
   l_fit:= :SYSTEM.CURSOR_ITEM;  
   -- get blank item name --
   l_bit:= substr(l_fit, instr(l_fit,'.')+1, length(l_fit)-instr(l_fit,'.'));  
   l_blk:= pkg_Item.item_name(l_bit).block;
   -- clear item --
   COPY(NULL, l_fit); 
   -- clear msg  --
   COPY(NULL, l_blk||'.'||'MSG_'||l_bit);
   -- activate underline      --
   Set_Item_Property(l_blk||'.'||'UNDER_'||l_bit, VISUAL_ATTRIBUTE, 'VA_UL_ACTIVE');  
   -- activate label          --
   prc_enable_item(l_blk||'.'||'LABEL_'||l_bit);
   Set_Item_Property(l_blk||'.'||'LABEL_'||l_bit, VISUAL_ATTRIBUTE, 'VA_TXT_LABEL_ACTIVE');   
   -- deactivate msg --
   Set_Item_Property(l_blk||'.'||'MSG_'||l_bit , VISIBLE, PROPERTY_FALSE);  
   -- activate input property --  
   Set_Item_Property(l_fit , VISUAL_ATTRIBUTE, 'VA_TEXT');   
   --
   IF pkg_Item.item_name(l_bit).type='SECURE' THEN
      -- hide text --
      Set_item_Property(l_blk||'.'||l_bit, ECHO, PROPERTY_FALSE); 	     
   END IF; 
   
  EXCEPTION WHEN OTHERS THEN
  	 prc_info('$$$ EXCEPTION in pkg_Item.prc_Enter: '||sqlerrm); 	 
END prc_Enter;
-----------------------------------------------------------------------------------
PROCEDURE prc_Leave IS
   l_blk      VARCHAR2(32);
   l_fit      VARCHAR2(32);
   l_bit      VARCHAR2(32);
   l_it_value VARCHAR2(64);
   l_vres     VARCHAR2(512);	
BEGIN		
  l_fit      := :SYSTEM.CURSOR_ITEM; 
  l_it_value := NAME_IN(l_fit); 
  l_bit      := substr(l_fit, instr(l_fit,'.')+1, length(l_fit)-instr(l_fit,'.'));  
  l_blk      := pkg_Item.item_name(l_bit).block;
  
  IF l_it_value IS NULL OR l_it_value=pkg_Item.item_name(l_bit).text THEN 	 	
     COPY(pkg_Item.item_name(l_bit).text, l_fit);
     COPY(pkg_Item.item_name(l_bit).label, l_blk||'.'||'LABEL_'||l_fit);  
     -- underline to empty  --
     Set_Item_Property(l_blk||'.'||'UNDER_'||l_bit , VISUAL_ATTRIBUTE, 'VA_UL_EMPTY');     	 
     -- deactivate label    --
     Set_Item_Property(l_blk||'.'||'LABEL_'||l_bit , VISIBLE, PROPERTY_FALSE);  
     --
     IF pkg_Item.item_name(l_bit).type='SECURE' THEN
  	-- hide text --
  	Set_item_Property(l_blk||'.'||l_bit, ECHO, PROPERTY_TRUE); 	     
     END IF; 	 
     -- activate insert property --  
     Set_Item_Property(l_fit , VISUAL_ATTRIBUTE, 'VA_TEXT_INSERT');         
  ELSE
     l_vres:= fnc_validate(l_bit);
     IF substr(l_vres,1,3)<>'$$$' THEN
   	IF l_vres NOT IN ('OK', 'LIGHT', 'MEDIUM', 'STRONG') THEN
   	   Set_Item_Property(l_blk||'.'||'LABEL_'||l_bit , VISUAL_ATTRIBUTE, 'VA_TXT_LABEL_ERROR');  
   	   -- underline to error full  --
   	   prc_enable_item(l_blk||'.'||'UNDER_'||l_bit);
   	   Set_Item_Property(l_blk||'.'||'UNDER_'||l_bit, VISUAL_ATTRIBUTE, 'VA_UL_ERROR'); 
	   COPY(l_vres, l_blk||'.'||'MSG_'||l_bit);
	   -- Set_Item_Property(pkg_Item.item_name(l_bit).block||'.'||'MSG_'||l_bit , VISUAL_ATTRIBUTE, fnc_sign_msg(l_vres));
	   prc_enable_item(l_blk||'.'||'MSG_'||l_bit);
   	ELSE
   	   Set_Item_Property(l_blk||'.'||'LABEL_'||l_bit , VISUAL_ATTRIBUTE, 'VA_TXT_LABEL_OK');
   	   prc_enable_item(l_blk||'.'||'UNDER_'||l_bit);
   		 	   Set_Item_Property(l_blk||'.'||'UNDER_'||l_bit , VISUAL_ATTRIBUTE, 'VA_UL_FULL'); 
   		 	   IF l_vres<>'OK' THEN
   		 	      prc_enable_item(l_blk||'.'||'MSG_'||l_bit);
   		 	      Set_Item_Property(l_blk||'.'||'MSG_'||l_bit , VISUAL_ATTRIBUTE, fnc_sign_msg(l_vres));
   		 	      COPY(l_vres, l_blk||'.'||'MSG_'||l_bit);
   		 	   END IF;
	   	  END IF;
   	 ELSE
   	    prc_enable_item(l_blk||'.'||'LABEL_'||l_bit); 	
   	    Set_Item_Property(l_blk||'.'||'LABEL_'||l_bit , VISUAL_ATTRIBUTE, 'VA_TXT_LABEL_ERROR');
  	    -- underline to error full  --
   	    prc_enable_item(l_blk||'.'||'UNDER_'||l_bit);
   	    Set_Item_Property(l_blk||'.'||'UNDER_'||l_bit, VISUAL_ATTRIBUTE, 'VA_UL_ERROR'); 
   	    -- error msg -- 
  	    COPY(l_vres, l_blk||'.'||'MSG_'||l_bit);
  	    prc_enable_item(l_blk||'.'||'MSG_'||l_bit);  
  	    Set_Item_Property(l_blk||'.'||'MSG_'||l_bit , VISUAL_ATTRIBUTE, 'VA_TXT_ERROR_MSG');   	    
  	 END IF; 	 
  END IF; 
  
  EXCEPTION WHEN OTHERS THEN
     prc_info('$$$ EXCEPTION in pkg_Item.prc_Leave: '||sqlerrm); 	
END prc_Leave;
-----------------------------------------------------------------------------------
FUNCTION fnc_final_check RETURN VARCHAR2 IS
   l_value VARCHAR2(64);
BEGIN
   FOR i IN 1.. pkg_Item.item_ix.count LOOP
       l_value:= NAME_IN(pkg_Item.item_ix(i).name);
       IF (l_value IS NULL AND pkg_Item.item_ix(i).notnull='YES') OR 
  	   	  -- item label text ? --
  	   	  (l_value=pkg_Item.item_ix(i).text AND pkg_Item.item_ix(i).notnull='YES') OR
  	   	  -- item error message ? --
  	   	  substr(NAME_IN(pkg_Item.item_name(pkg_Item.item_ix(i).name).block||'.'||
  	   	                 'MSG_'||pkg_Item.item_ix(i).name),1,3)='$$$' THEN 	   	  
  	   	  RETURN('Item: '|| pkg_Item.item_ix(i).name);
       END IF; 		 
   END LOOP;
   
   RETURN('OK'); 

 EXCEPTION WHEN OTHERS THEN
     prc_info('$$$ EXCEPTION in pkg_Item.fnc_final_check: '||sqlerrm); 	   
END fnc_final_check;
-----------------------------------------------------------------------------------
PROCEDURE prc_chk_item (p_block VARCHAR2, p_item VARCHAR2, p_value VARCHAR2, p_result VARCHAR2 DEFAULT NULL ) IS
   l_res VARCHAR2(16);  
BEGIN	
   go_item(p_block||'.'||p_item);
   IF p_value='GO' THEN 
      RETURN;
   ELSIF p_value='PRESS' THEN
      Execute_Trigger('WHEN-BUTTON-PRESSED');  
      sleep(100); 
   ELSE 
	 	   -- setter & getter item values --
			 Execute_Trigger('WHEN-NEW-ITEM-INSTANCE');  
			 Copy(p_value, p_block||'.'||p_item);
			 Execute_Trigger('WHEN-VALIDATE-ITEM');
			 sleep(150);
			 -- check expected/real result --
			 l_res:='OK';
			 IF (substr(NAME_IN(pkg_Item.item_name(p_item).block||'.'||'MSG_'||p_item) ,1,3)='$$$') THEN
			 	  l_res:='NOK';
			 END IF;
			 IF (l_res='NOK' AND p_result='OK') OR
		  	  ( (Name_In('MSG_'||p_item) IS NULL OR l_res='OK') AND p_result='NOK' )
		  	  THEN
		  	    prc_info('$$$ Error in automatic test sequence :: '||chr(10)||
		  	             'Item: '||p_item||chr(10)||
		  	             'Value:'||p_value||chr(10)||
		  	             'Result expected: '||p_result||chr(10)||
		  	             'Result real: '||l_res||chr(10)||' $$$');
		  	  RETURN;
			 END IF;			 
			 -- compare values : setter=getter ? --
			 IF Name_In(pkg_Item.item_name(p_item).block||'.'||p_item)<>p_value THEN
			 	  prc_info('$$$ Error in automatic test sequence :: '||chr(10)||
			 	           'Item: '||p_item||chr(10)||
			 	           'Value expected: '||p_value||chr(10)||
			 	           'Value real: '||Name_In(pkg_Item.item_name(p_item).block||'.'||p_item)||chr(10)||' $$$');
			 END IF; 
	 END IF; 
	 EXCEPTION WHEN OTHERS THEN
  	  prc_info('$$$ Exception in pkg_Item.prc_chk_Item: '||sqlerrm); 	 
END prc_chk_item;
-----------------------------------------------------------------------------------
-- !!! Used prc_Set_Items - defined from USER external procedure !!! --
-----------------------------------------------------------------------------------
PROCEDURE prc_rec (p_ix PLS_INTEGER, p_block VARCHAR2, p_name VARCHAR2, p_label VARCHAR2, p_text VARCHAR2, 
                   p_messg VARCHAR2 DEFAULT NULL, p_notnull VARCHAR2 DEFAULT 'YES', p_type VARCHAR2 DEFAULT 'NORMAL') IS
    l_label VARCHAR2(64);
    l_text  VARCHAR2(64);
BEGIN  	
   IF p_notnull='YES' THEN
  	  l_label:= p_label||' *';
  	  l_text := p_text||' *';
   ELSE
  	  l_label:= p_label;
  	  l_text := p_text;
   END IF;
	 -- 1. set name sorted tab --
	 pkg_Item.item_name(p_name).id		  := p_ix;
	 pkg_Item.item_name(p_name).block   := p_block;
	 pkg_Item.item_name(p_name).name	  := p_name;
	 pkg_Item.item_name(p_name).label   := l_label;
	 pkg_Item.item_name(p_name).text    := l_text;
	 pkg_Item.item_name(p_name).msg     := p_messg;  
	 pkg_Item.item_name(p_name).notnull := p_notnull;   
	 pkg_Item.item_name(p_name).type	 	:= p_type;
		    	  
	 -- 2. set ix sorted tab --
 	 pkg_Item.item_ix(p_ix).id		      := p_ix;
	 pkg_Item.item_ix(p_ix).block       := p_block;
	 pkg_Item.item_ix(p_ix).name	      := p_name;
 	 pkg_Item.item_ix(p_ix).label       := l_label;
	 pkg_Item.item_ix(p_ix).text        := l_text;
	 pkg_Item.item_ix(p_ix).msg         := p_messg;
	 pkg_Item.item_ix(p_ix).notnull     := p_notnull;
	 pkg_Item.item_ix(p_ix).type	      := p_type;	
		 		        
	EXCEPTION WHEN OTHERS THEN
  	 prc_info('$$$ Exception in pkg_Item.prc_init(rec): '||sqlerrm); 
END prc_rec;

PROCEDURE prc_init_Items IS 
  l_name VARCHAR2(32);
 BEGIN 	
 	 -- USER DEFINED - external !!! --
 	 prc_Set_Items;
 	 
   FOR i IN 1.. pkg_Item.item_ix.count LOOP
  	   l_name:= pkg_Item.item_ix(i).name; 	       
  	   COPY(pkg_Item.item_ix(i).text,  l_name);  
  	   COPY(pkg_Item.item_ix(i).label, 'LABEL_'||l_name);   
  	   -- specials --
  	   IF pkg_Item.item_ix(i).type='SECURE' THEN
  	  	  -- shows text --
  	      Set_item_Property(pkg_Item.item_ix(i).block||'.'||l_name, ECHO, PROPERTY_TRUE); 	     
  	   END IF; 	  
  	   Set_item_Property(pkg_Item.item_ix(i).block||'.UNDER_'||l_name, VISUAL_ATTRIBUTE, 'VA_UL_EMPTY');		 		  		 
   END LOOP;
  
 EXCEPTION WHEN OTHERS THEN
  	prc_info('$$$ EXCEPTION pkg_Item.prc_init: '||sqlerrm);	
 END prc_init_Items;

-----------------------------------------------------------------------------------

END;
PROCEDURE prc_Set_Items IS
   -- Friedhold Matz - 2018-FEB --
   -- item value definitions --
BEGIN
	 -- place your item definitions here . ! --
		 pkg_Item.prc_rec(1 , 'BLK_ACCOUNT', 'USERNAME', 		   'User name', 					 	
		                      'Enter your user name', 	         	   'Must begin with .. followed .. #_$');
		         
		 pkg_Item.prc_rec(2 , 'BLK_ACCOUNT', 'FULLNAME', 		   'Full name', 					
		                      'Enter your full name', 			   'Must begin with .. followed .. #_$');
		         
		 pkg_Item.prc_rec(3 , 'BLK_ACCOUNT', 'EMAIL',    		   'Email address', 				
		                      'Enter your first email address', 	   'Not a valid email format !');
		         
	 	 pkg_Item.prc_rec(4 , 'BLK_ACCOUNT', 'EMAIL2', 			   'Second email address',  
	 	                      'Enter your second email address',           'Not a valid email format !', 'NO');
	 	         
		 pkg_Item.prc_rec(5 , 'BLK_ACCOUNT', 'QUERY', 			   'Users query', 																				
		                      'Enter your query (e.g. "Name of my Cat")',  'Must begin with .. followed .. #_$');
		         
		 pkg_Item.prc_rec(6 , 'BLK_ACCOUNT', 'ANSWER',   		   'Users answer',          															
		 		       'Enter the answer of your query',           '.. ', 'YES', 'SECURE');
		 				 
		 pkg_Item.prc_rec(7 , 'BLK_ACCOUNT', 'PASSWORD',   	   	   'Password (3 lowers,3 uppers,3 numbers,3 specials)',   
		 		       'Enter the password (min. 12 characters)',  '.. Error message comes from intern ..', 'YES', 'SECURE');
		 				 
		 pkg_Item.prc_rec(8 , 'BLK_ACCOUNT', 'PASSWORD_RETRY',             'Retry password', 
		 		      'Re-enter the password',             	   '.. Error message comes from intern ..', 'YES', 'SECURE');	 
		 				 				 
  EXCEPTION WHEN OTHERS THEN
  	 prc_info('$$$ EXCEPTION pkg_Item.prc_Set_Items: '||sqlerrm);
END prc_Set_Items;

--- [EO showProgrammUnits] ---

--- [EO-FORM: {FORM-NAME:POC_ACCOUNT_FINAL2}] ---

