ScriptName FunctionalDisplaysContainerScript extends ObjectReference

;-- Structs -----------------------------------------
Struct FunctionalDisplaysStruct
	ObjectReference FDItemDisplayRef
	FDContainerItemType item

	{ This will hold the currently displayed FDItem reference. }
	string FunctionalDisplaysNode
	{ The node the FDItem should be placed at. }
EndStruct

Struct FDMountStruct
	ObjectReference FDMountItemDisplayRef
	string FDHorizontalNode
EndStruct

Struct FDContainerItemType
	int formId
	Form formObj
	int count
EndStruct


;-- Properties --------------------------------------
Keyword Property BobbleheadKeyword Auto Const
Keyword Property PerkMagKeyword Auto Const
Keyword Property ObjectTypeWeapon Auto Const
Keyword Property WeaponTypePistol Auto Const
Keyword Property WeaponTypeRifle Auto Const
Keyword Property WeaponTypeMelee1H Auto Const
Keyword Property WeaponTypeMelee2H Auto Const
Keyword Property WeaponTypeHeavyGun Auto Const
Keyword Property WeaponTypeHandToHand Auto Const
Keyword Property WeaponTypeMine Auto Const
Keyword Property WeaponTypeThrown Auto Const
Keyword Property WeaponTypeGrenade Auto Const
Keyword Property ObjectTypeAmmo Auto Const
Keyword Property ObjectTypeSyringerAmmo Auto Const
Keyword Property AnimFurnWater Auto Const
Keyword Property ObjectTypeWater Auto Const
Keyword Property ObjectTypeDrink Auto Const
Keyword Property ObjectTypeNukaCola Auto Const
Keyword Property ObjectTypeAlcohol Auto Const
Keyword Property ObjectTypeFood Auto Const
Keyword Property ObjectTypeStimpak Auto Const
Keyword Property ObjectTypeChem Auto Const
Keyword Property NotJunkJetAmmo Auto Const
Keyword Property BlockWorkshopInteractionKeyword Auto Const
Keyword Property FeaturedItem Auto Const
FDContainerItemType[] Property FDItemsInContainer Auto
Form[] Property FDMountItemsInContainer Auto
{ Array of current DisplayedItems that are in the container. }
FunctionalDisplaysStruct[] Property FunctionalDisplaysStructArray Auto
FDContainerItemType[] Property FDContainerItemTypeArray Auto
{ Struct Array of each display DisplayedItem ref, and the node it should go to. }
Message Property FunctionalDisplaysContainerFullMessage Auto
Message Property FunctionalDisplaysContainerWrongMessage Auto

;-- Variables ---------------------------------------
bool AlreadyLoaded

;-- Functions ---------------------------------------

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	Debug.Trace("OnItemRemoved called!", 2)     
	
	int count = 0
	while (count < FDContainerItemTypeArray.length)
		if (FDContainerItemTypeArray[count].formId == akBaseItem.GetFormID())
			FDContainerItemTypeArray[count].count -= aiItemCount
			Debug.Trace("OnItemRemoved removed "+akBaseItem.GetFormID()+" "+aiItemCount+" times", 2) 
			if(FDContainerItemTypeArray[count].count <= 0)
				FDContainerItemTypeArray.Remove(count)
			endif
			count = 129
		endif
		count += 1
	endwhile    
EndEvent

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	Debug.Trace("OnItemAdded called! aiItemCount: "+ aiItemCount, 2)

	
	int count = 0
	int hasfound = 0
	if (!IsWeapon(akBaseItem) && !IsSpecialItem(akBaseItem))
		While (count < FDContainerItemTypeArray.Length)
			Debug.Trace("OnItemAdded: searching for item type", 2)
			If (FDContainerItemTypeArray[count].formId == akBaseItem.GetFormID())
				FDContainerItemTypeArray[count].count += aiItemCount
				Debug.Trace("OnItemAdded: item type ("+akBaseItem.GetFormID()+") found item count: "+FDContainerItemTypeArray[count].count, 2)
				hasfound = 1
			EndIf
			count += 1
		EndWhile
	EndIf

	if(hasfound == 0)
		if(!IsWeapon(akBaseItem) && !IsSpecialItem(akBaseItem))
			FDContainerItemType item = new FDContainerItemType
			item.formId = akBaseItem.GetFormID()
			item.formObj = akBaseItem
			
			item.count = aiItemCount
			FDContainerItemTypeArray.Add(item)
			Debug.Trace("OnItemAdded: new item type added ("+akBaseItem.GetFormID()+"). Item TYPE count: "+FDContainerItemTypeArray.Length, 2)
		else
			int aicounter = 0
			While (aicounter < aiItemCount)
				FDContainerItemType item = new FDContainerItemType
				item.formId = akBaseItem.GetFormID()
				item.formObj = akBaseItem
				item.count = 1
				FDContainerItemTypeArray.Add(item)
				Debug.Trace("OnItemAdded: new item type added ("+akBaseItem.GetFormID()+"). Item TYPE count: "+FDContainerItemTypeArray.Length, 2)		
				aicounter += 1	
			endwhile
		endif
	EndIf
return

	;/ Debug.Trace("OnItemAdded: item rejected", 2)
	Self.RemoveItem(akBaseItem, aiItemCount, False, Game.GetPlayer() as ObjectReference)
	FunctionalDisplaysContainerWrongMessage.Show(0, 0, 0, 0, 0, 0, 0, 0, 0) /;
EndEvent

Function DisplayFDItems()
	Debug.Trace("DisplayFDItems called!", 2) 
	int MaxCount = FunctionalDisplaysStructArray.length
	If (MaxCount > 0)
		int Count = 0
		While (Count < MaxCount && Count < FDItemsInContainer.Length)
			if(!FunctionalDisplaysStructArray[Count].FDItemDisplayRef)
				Debug.Trace("DisplayFDItems Item: Displaying: "+FDItemsInContainer[Count].formId, 2)
				FDContainerItemType item = FDItemsInContainer[Count]
				FunctionalDisplaysStructArray[Count].item = item
				if(IsWeapon(item.formObj) || IsSpecialItem(item.formObj))
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef = Self.DropObject(FDItemsInContainer[Count].formobj,1)
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.MoveToNode(self,FunctionalDisplaysStructArray[Count].FunctionalDisplaysNode)
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.WaitFor3DLoad()
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetMotionType(Self.Motion_Keyframed, False)
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SplineTranslateToRefNode(Self, FunctionalDisplaysStructArray[Count].FunctionalDisplaysNode, 0, 10000, 0)
				else
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef = Self.PlaceAtNode(FunctionalDisplaysStructArray[Count].FunctionalDisplaysNode, item.formObj, item.count, False, False, False, True)
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetMotionType(Self.Motion_Keyframed, False)
				endif
				Self.RegisterForRemoteEvent(FunctionalDisplaysStructArray[Count].FDItemDisplayRef, "OnContainerChanged")
				FunctionalDisplaysStructArray[Count].FDItemDisplayRef.AddKeyword(BlockWorkshopInteractionKeyword) 
			endif
			Count += 1
		EndWhile
	EndIf
EndFunction

Event ObjectReference.OnContainerChanged(ObjectReference akSender, ObjectReference akNewContainer, ObjectReference akOldContainer)
	Debug.Trace("OnContainerChanged called!", 2) 
	Self.UnregisterForRemoteEvent(akSender, "OnContainerChanged")
	akSender.RemoveKeyword(BlockWorkshopInteractionKeyword)

	FunctionalDisplaysStruct itemTaken = new FunctionalDisplaysStruct
	int i = 0
	bool stop = false
	While (i < FunctionalDisplaysStructArray.length && !stop)
		if(FunctionalDisplaysStructArray[i].FDItemDisplayRef == akSender)
			itemTaken = FunctionalDisplaysStructArray[i]
			stop = true
		else
			i += 1
		endif
	EndWhile
	Debug.Trace("OnContainerChanged called 1! "+i, 2) 

	If (!IsWeapon(itemTaken.FDItemDisplayRef) && !IsSpecialItem(itemTaken.FDItemDisplayRef))
		Self.RemoveItem(itemTaken.item.formObj, itemTaken.item.count, False, None)
		Utility.Wait(0.1)
	endif
	Debug.Trace("OnContainerChanged called! 2", 2) 
	FunctionalDisplaysStructArray[i].FDItemDisplayRef = none
	FunctionalDisplaysStructArray[i].item = none

	
	Debug.Trace("OnContainerChanged called!3", 2) 
	if(IsWeapon(akSender) || IsSpecialItem(akSender))
		Self.DeleteFDItems()
		Self.RecalculateFDItemsInContainer()
		Debug.Trace("OnContainerChanged called4!", 2) 
	elseif !Self.RecalculateFDItemsInContainer()
		Self.DeleteFDItems()
	endif


	Debug.Trace("OnContainerChanged called5!", 2) 
	Self.DisplayFDItems()
EndEvent

Function DeleteFDItems()
	Debug.Trace("DeleteFDItems called!", 2)
	int MaxCount = FunctionalDisplaysStructArray.length
	int Count = 0
	While (Count < MaxCount)
		If (FunctionalDisplaysStructArray[Count].FDItemDisplayRef)
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.DisableNoWait(False)
			if(IsWeapon(FunctionalDisplaysStructArray[Count].FDItemDisplayRef) || IsSpecialItem(FunctionalDisplaysStructArray[Count].FDItemDisplayRef))
				Self.UnregisterForRemoteEvent(FunctionalDisplaysStructArray[Count].FDItemDisplayRef, "OnContainerChanged")
				Self.AddItem(FunctionalDisplaysStructArray[Count].FDItemDisplayRef)
			else
				FunctionalDisplaysStructArray[Count].FDItemDisplayRef.Delete()
			endif
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef = None
			FunctionalDisplaysStructArray[Count].item = None
		EndIf
		Count += 1
	EndWhile
	
	Utility.Wait(0.1)
EndFunction

bool Function RecalculateFDItemsInContainer()
	Debug.Trace("RecalculateFDItemsInContainer called!", 2)
	FDContainerItemType[] FDItemsInContainerNew = new FDContainerItemType[0]

	int count = 0
	
	While (FDContainerItemTypeArray.Length > count)
		FDContainerItemType item = FDContainerItemTypeArray[count]

		int nextItemCountToDisplay = 10
		int itemCountLeft = item.count
		While (itemCountLeft>0)
			FDContainerItemType displayItem = new FDContainerItemType
			displayItem.formId = item.formId
			displayItem.formObj = item.formObj

			if(nextItemCountToDisplay <= itemCountLeft)
				itemCountLeft -= nextItemCountToDisplay
			else
				nextItemCountToDisplay = itemCountLeft
				itemCountLeft = 0
			endif

			if(item.formObj.HasKeyword(ObjectTypeAmmo) && !IsWeapon(item.formObj) && !IsSpecialItem(item.formObj))
				displayItem.count = nextItemCountToDisplay
			else
				displayItem.count = 1
			endif
			
			FDItemsInContainerNew.add(displayItem)
			Debug.Trace("RecalculateFDItemsInContainer: added item to display by place: "+displayItem.formId+" "+displayItem.count+" times", 2)
			nextItemCountToDisplay *= 10
		EndWhile

		count += 1
	EndWhile

	count = 0

	While (FunctionalDisplaysStructArray.Length > count)
		if(FunctionalDisplaysStructArray[count].FDItemDisplayRef && (IsWeapon(FunctionalDisplaysStructArray[count].FDItemDisplayRef) || IsSpecialItem(FunctionalDisplaysStructArray[count].FDItemDisplayRef)))
			FDContainerItemType displayItem = new FDContainerItemType
			displayItem.formId = FunctionalDisplaysStructArray[count].FDItemDisplayRef.GetFormID()
			displayItem.formObj = FunctionalDisplaysStructArray[count].FDItemDisplayRef.GetBaseObject()
			displayItem.count = 1
			FDItemsInContainerNew.add(displayItem)
			Debug.Trace("RecalculateFDItemsInContainer: added item to display by drop: "+displayItem.formId, 2)
		endif
		count += 1
	endwhile

	bool same = true
	if (FDItemsInContainer.Length == FDItemsInContainerNew.Length)
		count = 0
		while (same && count < FDItemsInContainer.Length)
			same = FDItemsInContainer[count].formId == FDItemsInContainerNew[count].formId && FDItemsInContainer[count].count == FDItemsInContainerNew[count].count
			count += 1
		endwhile
	else
		same = false
	endif

	FDItemsInContainer = FDItemsInContainerNew

	return same 
EndFunction

Event OnLoad()
	If (!AlreadyLoaded)
		AlreadyLoaded = True
		FDItemsInContainer = new FDContainerItemType[0]
		FDContainerItemTypeArray = new FDContainerItemType[0]
		FDMountItemsInContainer = new Form[0]
	EndIf
EndEvent





Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)

EndEvent

Function DoThing()
	; Empty function
EndFunction
	
Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	Self.DeleteFDItems()
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	Self.DisplayFDItems()
	
	;	int MaxCount = FunctionalDisplaysStructArray.length
	;	If (MaxCount > 0)
	;		int Count = 0
	;		
	;		While (Count < MaxCount)
	;			if(FunctionalDisplaysStructArray[Count].FDItemDisplayRef)
	;				Form akBaseItem = FunctionalDisplaysStructArray[Count].FDItemDisplayRef.GetBaseObject()
	;				if(IsWeapon(akBaseItem) || IsSpecialItem(akBaseItem))
	;					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SplineTranslateToRefNode(Self, FunctionalDisplaysStructArray[Count].FunctionalDisplaysNode, 0, 10000, 0)
	;				endif
	;			endif
	;			Count += 1
	;		EndWhile
	;	EndIf
	
EndEvent

bool Function IsWeapon(Form akBaseItem)
    bool res = false
    res = res || akBaseItem.HasKeyword(ObjectTypeWeapon) 
    res = res || akBaseItem.HasKeyword(WeaponTypePistol) 
    res = res || akBaseItem.HasKeyword(WeaponTypeRifle) 
    res = res || akBaseItem.HasKeyword(WeaponTypeMelee1H) 
    res = res || akBaseItem.HasKeyword(WeaponTypeMelee2H) 
    res = res || akBaseItem.HasKeyword(WeaponTypeHeavyGun)
    res = res || akBaseItem.HasKeyword(WeaponTypeHandToHand)
    res = res && !akBaseItem.HasKeyword(WeaponTypeThrown) && !akBaseItem.HasKeyword(WeaponTypeGrenade) ;&& !akBaseItem.HasKeyword(WeaponTypePulseGrenade)
    Debug.Trace(akBaseItem.GetFormID() + " IsWeapon: "+res, 2)
    return res
EndFunction

bool Function IsSpecialItem(Form akBaseItem)
	bool res = false
	;res = res || akBaseItem.HasKeyword(FDIItemSpecial)
    ;Debug.Trace(akBaseItem.GetFormID() + " IsSpecialItem: "+res, 2)
    return res
EndFunction

;-- State -------------------------------------------
Auto State AllowActivate

	Event OnActivate(ObjectReference akActionRef)
		Self.GoToState("Busy")
		Self.BlockActivation(True, False)
		Self.AddInventoryEventFilter(None)
		If (akActionRef == Game.GetPlayer() as ObjectReference)
			Self.DeleteFDItems()
			if(Self.GetItemCount() == 0)
				FDItemsInContainer = new FDContainerItemType[0]
				FDContainerItemTypeArray = new FDContainerItemType[0]
				FDMountItemsInContainer = new Form[0]
			ENDIF
			Self.RecalculateFDItemsInContainer()
			Self.DisplayFDItems()
		EndIf

		Self.GoToState("AllowActivate")
		Self.BlockActivation(False, False)
	EndEvent
EndState

;-- State -------------------------------------------
State Busy
EndState