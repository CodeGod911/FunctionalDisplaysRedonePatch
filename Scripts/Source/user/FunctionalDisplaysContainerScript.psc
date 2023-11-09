ScriptName FunctionalDisplaysContainerScript extends ObjectReference

;-- Structs -----------------------------------------
Struct FunctionalDisplaysStruct
	ObjectReference FDItemDisplayRef
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
Form[] Property FDItemsInContainer Auto
FDContainerItemType[] Property FDWeaponsInContainer Auto
Form[] Property FDMountItemsInContainer Auto
{ Array of current DisplayedItems that are in the container. }
FunctionalDisplaysStruct[] Property FunctionalDisplaysStructArray Auto
FDMountStruct[] Property FDMountStructArray Auto
FDContainerItemType[] Property FDContainerItemTypeArray Auto
{ Struct Array of each display DisplayedItem ref, and the node it should go to. }
Message Property FunctionalDisplaysContainerFullMessage Auto
Message Property FunctionalDisplaysContainerWrongMessage Auto

;-- Variables ---------------------------------------
bool AlreadyLoaded

;-- Functions ---------------------------------------

Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	Debug.Trace("OnItemRemoved called!", 2) 
	If ( akBaseItem.HasKeyword(BobbleheadKeyword) || akBaseItem.HasKeyword(PerkMagKeyword) || akBaseItem.HasKeyword(WeaponTypeMine) || akBaseItem.HasKeyword(WeaponTypeGrenade) || akBaseItem.HasKeyword(ObjectTypeAmmo) || akBaseItem.HasKeyword(ObjectTypeSyringerAmmo) || akBaseItem.HasKeyword(AnimFurnWater) || akBaseItem.HasKeyword(ObjectTypeWater) || akBaseItem.HasKeyword(ObjectTypeDrink) || akBaseItem.HasKeyword(ObjectTypeNukaCola) || akBaseItem.HasKeyword(ObjectTypeAlcohol) || akBaseItem.HasKeyword(ObjectTypeFood) || akBaseItem.HasKeyword(ObjectTypeStimpak) || akBaseItem.HasKeyword(ObjectTypeChem) || akBaseItem.HasKeyword(NotJunkJetAmmo) || akBaseItem.HasKeyword(FeaturedItem))
		int count = 0
		while (count < FDContainerItemTypeArray.length)
			if (FDContainerItemTypeArray[count].formId == akBaseItem.GetFormID())
				FDContainerItemTypeArray[count].count -= aiItemCount
				if(FDContainerItemTypeArray[count].count <= 0)
					FDContainerItemTypeArray.Remove(count)
				endif
				count = 129
			endif
			count += 1
		endwhile
	EndIf
	;If (akBaseItem.HasKeyword(ObjectTypeWeapon) || akBaseItem.HasKeyword(WeaponTypePistol) || akBaseItem.HasKeyword(WeaponTypeRifle) || akBaseItem.HasKeyword(WeaponTypeMelee1H) || akBaseItem.HasKeyword(WeaponTypeMelee2H) || akBaseItem.HasKeyword(WeaponTypeHeavyGun) || akBaseItem.HasKeyword(WeaponTypeHandToHand) || akBaseItem.HasKeyword(WeaponTypeThrown))
	;	int count = 0
	;	while (count < FDWeaponsInContainer.length)
	;		if (FDWeaponsInContainer[count] == akBaseItem)
	;			FDWeaponsInContainer.Remove(count)
	;			count = 129
	;		endif
	;		count += 1
	;	endwhile
	;endif
EndEvent

Function DisplayFDItems()
	Debug.Trace("DisplayFDItems called!", 2) 
	int MaxCount = FunctionalDisplaysStructArray.length
	If (MaxCount > 0)
		int Count = 0
		int ContainerCount = 0
		While (Count < FDItemsInContainer.Length)
			if(!FunctionalDisplaysStructArray[Count].FDItemDisplayRef)
				Debug.Trace("DisplayFDItems Item: Displaying: "+FDItemsInContainer[Count].GetFormID(), 2)
				FunctionalDisplaysStructArray[Count].FDItemDisplayRef = Self.PlaceAtNode(FunctionalDisplaysStructArray[Count].FunctionalDisplaysNode, FDItemsInContainer[Count], 1, False, False, False, True)
				Self.RegisterForRemoteEvent(FunctionalDisplaysStructArray[Count].FDItemDisplayRef, "OnContainerChanged")
				FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetMotionType(Self.Motion_Keyframed, False)
				FunctionalDisplaysStructArray[Count].FDItemDisplayRef.AddKeyword(BlockWorkshopInteractionKeyword)
				;FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetNoFavorAllowed(True)
				;FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetPlayerHasTaken(True)
			endif
			Count += 1
		EndWhile

		ContainerCount = 0
		While (Count < MaxCount && ContainerCount < FDWeaponsInContainer.Length)
			While (Count < MaxCount && Self.GetItemCount(FDWeaponsInContainer[ContainerCount].formObj)>0)
				if(!FunctionalDisplaysStructArray[Count].FDItemDisplayRef)
					Debug.Trace("DisplayFDItems: Displaying: "+FDWeaponsInContainer[ContainerCount].formObj.GetFormID(), 2)
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef = Self.DropObject(FDWeaponsInContainer[ContainerCount].formobj,1)
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.WaitFor3DLoad()
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetMotionType(Self.Motion_Keyframed, False)
					Self.RegisterForRemoteEvent(FunctionalDisplaysStructArray[Count].FDItemDisplayRef, "OnContainerChanged")
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.AddKeyword(BlockWorkshopInteractionKeyword)
					FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SplineTranslateToRefNode(Self, FunctionalDisplaysStructArray[Count].FunctionalDisplaysNode, 0, 10000, 0)
					;FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetNoFavorAllowed(True)
					;FunctionalDisplaysStructArray[Count].FDItemDisplayRef.SetPlayerHasTaken(True)
				endif
				Count += 1
			EndWhile
			ContainerCount += 1
		EndWhile
	EndIf
EndFunction

Event ObjectReference.OnContainerChanged(ObjectReference akSender, ObjectReference akNewContainer, ObjectReference akOldContainer)
	Debug.Trace("OnContainerChanged called!", 2) 
	Self.UnregisterForRemoteEvent(akSender, "OnContainerChanged")
	akSender.RemoveKeyword(BlockWorkshopInteractionKeyword)
	
	Form akBaseItem = akSender.GetBaseObject()
	If (akBaseItem.HasKeyword(BobbleheadKeyword) || akBaseItem.HasKeyword(PerkMagKeyword) || akBaseItem.HasKeyword(WeaponTypeMine) || akBaseItem.HasKeyword(WeaponTypeGrenade) || akBaseItem.HasKeyword(ObjectTypeAmmo) || akBaseItem.HasKeyword(ObjectTypeSyringerAmmo) || akBaseItem.HasKeyword(AnimFurnWater) || akBaseItem.HasKeyword(ObjectTypeWater) || akBaseItem.HasKeyword(ObjectTypeDrink) || akBaseItem.HasKeyword(ObjectTypeNukaCola) || akBaseItem.HasKeyword(ObjectTypeAlcohol) || akBaseItem.HasKeyword(ObjectTypeFood) || akBaseItem.HasKeyword(ObjectTypeStimpak) || akBaseItem.HasKeyword(ObjectTypeChem) || akBaseItem.HasKeyword(NotJunkJetAmmo) || akBaseItem.HasKeyword(FeaturedItem))
		Self.RemoveItem(akBaseItem, 1, False, None)
	endif

	Utility.Wait(0.1)

	int count = 0
	while (count < FunctionalDisplaysStructArray.length)
		if (FunctionalDisplaysStructArray[count].FDItemDisplayRef == akSender)
			FunctionalDisplaysStructArray[count].FDItemDisplayRef = none
			count = 999
		endif
		count += 1
	endwhile
	
	if(!Self.RecalculateFDItemsInContainer())
		Self.DeleteFDItems()
	endif
	Self.DisplayFDItems()
EndEvent

Function DeleteFDItems()
	Debug.Trace("DeleteFDItems called!", 2)
	int MaxCount = FunctionalDisplaysStructArray.length
	int Count = 0
	While (Count < MaxCount)
		If (FunctionalDisplaysStructArray[Count].FDItemDisplayRef && !(FunctionalDisplaysStructArray[Count].FDItemDisplayRef.HasKeyword(ObjectTypeWeapon) || FunctionalDisplaysStructArray[Count].FDItemDisplayRef.HasKeyword(WeaponTypePistol) || FunctionalDisplaysStructArray[Count].FDItemDisplayRef.HasKeyword(WeaponTypeRifle) || FunctionalDisplaysStructArray[Count].FDItemDisplayRef.HasKeyword(WeaponTypeMelee1H) || FunctionalDisplaysStructArray[Count].FDItemDisplayRef.HasKeyword(WeaponTypeMelee2H) || FunctionalDisplaysStructArray[Count].FDItemDisplayRef.HasKeyword(WeaponTypeHeavyGun) || FunctionalDisplaysStructArray[Count].FDItemDisplayRef.HasKeyword(WeaponTypeHandToHand) || FunctionalDisplaysStructArray[Count].FDItemDisplayRef.HasKeyword(WeaponTypeThrown)))
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.DisableNoWait(False)
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef.Delete()
			FunctionalDisplaysStructArray[Count].FDItemDisplayRef = None
		EndIf
		Count += 1
	EndWhile
EndFunction

bool Function RecalculateFDItemsInContainer()
	;Debug.Trace("RecalculateFDItemsInContainer called!", 2)
	Form[] FDItemsInContainerNew = new Form[0]
	int MaxCount = FunctionalDisplaysStructArray.length
	int count = 0
	int displayedcount = 0
	while (MaxCount > displayedcount && FDContainerItemTypeArray.Length > count)
		FDContainerItemType item = FDContainerItemTypeArray[count]
		int todisplay = Self.Log10(item.count)
		if(count + todisplay > maxcount)
			todisplay = maxcount - count  
		endif
		int displayed = 0
		;Debug.Trace("RecalculateFDItemsInContainer: displaying item: "+item.formId+" "+todisplay+" times", 2)
		while (displayed < todisplay)
			FDItemsInContainerNew.add(item.formObj,1)
			;Debug.Trace("RecalculateFDItemsInContainer: added item to display: "+item.formId, 2)
			displayed += 1
		endwhile
		displayedcount += todisplay
		count += 1
	endwhile

	bool same = true
	if (FDItemsInContainer.Length == FDItemsInContainerNew.Length)
		count = 0
		while (same && count < FDItemsInContainer.Length)
			same = FDItemsInContainer[count].GetFormID() == FDItemsInContainerNew[count].GetFormID()
			count += 1
		endwhile
	else
		same = false
	endif

	FDItemsInContainer = FDItemsInContainerNew

	return same 
EndFunction


Function DeleteFDMountItems()
	Debug.Trace("DeleteFDMountItems called!", 2)
	int MaxCount = FDMountStructArray.length
	int Count = 0
	While (Count < MaxCount)
		If (FDMountStructArray[Count].FDMountItemDisplayRef != none)
			FDMountStructArray[Count].FDMountItemDisplayRef.DisableNoWait(False)
			FDMountStructArray[Count].FDMountItemDisplayRef.Delete()
			FDMountStructArray[Count].FDMountItemDisplayRef = None
		EndIf
		Count += 1
	EndWhile
EndFunction


Event OnLoad()
	If (!AlreadyLoaded)
		AlreadyLoaded = True
		FDItemsInContainer = new Form[0]
		FDContainerItemTypeArray = new FDContainerItemType[0]
		FDMountItemsInContainer = new Form[0]
		FDWeaponsInContainer = new FDContainerItemType[0]
	EndIf
EndEvent


int Function Log10(int number)
	int result = 0
	int power = 1
	While (number >= power)
		power *= 10
		result += 1
	EndWhile
	return result
EndFunction

int Function Stack10(int number)
	int result = (number - 1) / 10+1
	return result
EndFunction

int Function to1(int number)
	return number
EndFunction

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	Debug.Trace("OnItemAdded called! aiItemCount: "+ aiItemCount, 2)

	if (akBaseItem.HasKeyword(ObjectTypeWeapon) || akBaseItem.HasKeyword(WeaponTypePistol) || akBaseItem.HasKeyword(WeaponTypeRifle) || akBaseItem.HasKeyword(WeaponTypeMelee1H) || akBaseItem.HasKeyword(WeaponTypeMelee2H) || akBaseItem.HasKeyword(WeaponTypeHeavyGun) || akBaseItem.HasKeyword(WeaponTypeHandToHand) || akBaseItem.HasKeyword(WeaponTypeThrown))
			int itemCount = 0
			while (itemCount < aiItemCount)
				int count = 0
				int freespace = 0
				while(count < FunctionalDisplaysStructArray.length)
					if (!FunctionalDisplaysStructArray[count].FDItemDisplayRef)
						freespace += 1
					endif
					count += 1
				endwhile
				If (freespace - Self.GetItemCount() < 0)
					Self.RemoveItem(akBaseItem, aiItemCount, False, Game.GetPlayer() as ObjectReference)
					FunctionalDisplaysContainerFullMessage.Show(0, 0, 0, 0, 0, 0, 0, 0, 0)
					return
				Else
					FDContainerItemType item = new FDContainerItemType
					item.formObj = akBaseItem
					FDWeaponsInContainer.Add(item)
				EndIf
				itemCount += 1
			endwhile
			return
	Else 
		If (akBaseItem.HasKeyword(BobbleheadKeyword) || akBaseItem.HasKeyword(PerkMagKeyword) || akBaseItem.HasKeyword(WeaponTypeGrenade) || akBaseItem.HasKeyword(ObjectTypeAmmo) || akBaseItem.HasKeyword(WeaponTypeMine) || akBaseItem.HasKeyword(ObjectTypeSyringerAmmo) || akBaseItem.HasKeyword(AnimFurnWater) || akBaseItem.HasKeyword(ObjectTypeWater) || akBaseItem.HasKeyword(ObjectTypeDrink) || akBaseItem.HasKeyword(ObjectTypeNukaCola) || akBaseItem.HasKeyword(ObjectTypeAlcohol) || akBaseItem.HasKeyword(ObjectTypeFood) || akBaseItem.HasKeyword(ObjectTypeStimpak) || akBaseItem.HasKeyword(ObjectTypeChem) || akBaseItem.HasKeyword(NotJunkJetAmmo) || akBaseItem.HasKeyword(FeaturedItem))
			Debug.Trace("OnItemAdded: item accepted", 2)
			
			int count = 0
			int hasfound = 0
			While (count < FDContainerItemTypeArray.Length)
				Debug.Trace("OnItemAdded: searching for item type", 2)
				If (FDContainerItemTypeArray[count].formId == akBaseItem.GetFormID())
					FDContainerItemTypeArray[count].count += aiItemCount
					Debug.Trace("OnItemAdded: item type ("+akBaseItem.GetFormID()+") found item count: "+FDContainerItemTypeArray[count].count, 2)
					hasfound = 1
				EndIf
				count += 1
			EndWhile

			if(hasfound == 0)
				FDContainerItemType item = new FDContainerItemType
				item.formId = akBaseItem.GetFormID()
				item.formObj = akBaseItem
				item.count = aiItemCount
				FDContainerItemTypeArray.Add(item)
				Debug.Trace("OnItemAdded: new item type added ("+akBaseItem.GetFormID()+"). Item type count: "+FDContainerItemTypeArray.Length, 2)
			EndIf
			return
		endif
	EndIf

	Debug.Trace("OnItemAdded: item rejected", 2)
	Self.RemoveItem(akBaseItem, aiItemCount, False, Game.GetPlayer() as ObjectReference)
	FunctionalDisplaysContainerWrongMessage.Show(0, 0, 0, 0, 0, 0, 0, 0, 0)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	Self.DeleteFDItems()
	Self.DeleteFDMountItems()
EndEvent

Function DoThing()
	; Empty function
EndFunction

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	; Empty function
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	; Empty function
EndEvent

;-- State -------------------------------------------
Auto State AllowActivate

	Event OnActivate(ObjectReference akActionRef)
		Self.GoToState("Busy")
		Self.BlockActivation(True, False)
		Self.AddInventoryEventFilter(None)
		If (akActionRef == Game.GetPlayer() as ObjectReference)
			Self.DeleteFDItems()
			Self.DeleteFDMountItems()
			Utility.Wait(0.1)
			if(Self.GetItemCount() == 0)
				FDItemsInContainer = new Form[0]
				FDContainerItemTypeArray = new FDContainerItemType[0]
				FDMountItemsInContainer = new Form[0]
				FDWeaponsInContainer = new FDContainerItemType[0]
			ENDIF
			Self.RecalculateFDItemsInContainer()
			Self.DisplayFDItems()
		EndIf

		Debug.Trace(BobbleheadKeyword.GetFormID())
		Debug.Trace(PerkMagKeyword.GetFormID())
		Debug.Trace(ObjectTypeWeapon.GetFormID())
		Debug.Trace(WeaponTypePistol.GetFormID())
		Debug.Trace(WeaponTypeRifle.GetFormID())
		Debug.Trace(WeaponTypeMelee1H.GetFormID())
		Debug.Trace(WeaponTypeMelee2H.GetFormID())
		Debug.Trace(WeaponTypeHeavyGun.GetFormID())
		Debug.Trace(WeaponTypeHandToHand.GetFormID())
		Debug.Trace(WeaponTypeMine.GetFormID())
		Debug.Trace(WeaponTypeThrown.GetFormID())
		Debug.Trace(WeaponTypeGrenade.GetFormID())
		Debug.Trace(ObjectTypeAmmo.GetFormID())
		Debug.Trace(ObjectTypeSyringerAmmo.GetFormID())
		Debug.Trace(AnimFurnWater.GetFormID())
		Debug.Trace(ObjectTypeWater.GetFormID())
		Debug.Trace(ObjectTypeDrink.GetFormID())
		Debug.Trace(ObjectTypeNukaCola.GetFormID())
		Debug.Trace(ObjectTypeAlcohol.GetFormID())
		Debug.Trace(ObjectTypeFood.GetFormID())
		Debug.Trace(ObjectTypeStimpak.GetFormID())
		Debug.Trace(ObjectTypeChem.GetFormID())
		Debug.Trace(NotJunkJetAmmo.GetFormID())
		Debug.Trace(BlockWorkshopInteractionKeyword.GetFormID())
		Debug.Trace(FeaturedItem.GetFormID())
		Self.GoToState("AllowActivate")
		Self.BlockActivation(False, False)
	EndEvent
EndState

;-- State -------------------------------------------
State Busy
EndState