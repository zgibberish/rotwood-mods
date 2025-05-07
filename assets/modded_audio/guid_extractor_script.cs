using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameObject : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        FMOD.RESULT result = FMODUnity.RuntimeManager.StudioSystem.getBankCount(out int  bankCount);
        if (result != FMOD.RESULT.OK)
        {
            Debug.Log(result.ToString());
            return;
        }

        FMOD.Studio.Bank[] Banks = new FMOD.Studio.Bank[bankCount];
        FMODUnity.RuntimeManager.StudioSystem.getBankList(out Banks);

        for (int i = 0; i < bankCount; i++)
        {
        	Banks[i].getPath(out string bankPath);
        	Banks[i].getID(out FMOD.GUID bankID);
        	Debug.Log(bankID.ToString() + "    " + bankPath);

			Banks[i].getBusCount(out int bankBusCount);
			FMOD.Studio.Bus[] Buses = new FMOD.Studio.Bus[bankBusCount];
			Banks[i].getBusList(out Buses);
			for (int j = 0; j < bankBusCount; j++)
			{
				Buses[j].getPath(out string busPath);
				Buses[j].getID(out FMOD.GUID busGUID);
				Debug.Log("  " + busGUID.ToString() + "    " + busPath);
			}
			
			Banks[i].getVCACount(out int bankVCACount);
			FMOD.Studio.VCA[] VCAs = new FMOD.Studio.VCA[bankVCACount];
			Banks[i].getVCAList(out VCAs);
			for (int j = 0; j < bankVCACount; j++)
			{
				VCAs[j].getPath(out string vcaPath);
				VCAs[j].getID(out FMOD.GUID vcaGUID);
				Debug.Log("  " + vcaGUID.ToString() + "    " + vcaPath);
			}
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
