#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo = 
{
    name = "No Damage - Entre Times",
    author = "SERASA & EV",
    description = "Desabilita o dano entre jogadores de times diferentes",
    version = "1.0",
    url = "https://www.gametracker.com/server_info/191.209.110.83:27015/"
};

bool g_NoDamageEnabled = true;

public void OnPluginStart()
{
    RegAdminCmd("sm_toggle_nodamage", Command_ToggleNoDamage, ADMFLAG_GENERIC, "Ativa ou desativa a proteção contra dano entre jogadores (exceto auto-dano).");

    // Hook de dano
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
        }
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!g_NoDamageEnabled)
    {
        return Plugin_Continue;
    }

    if (victim == attacker)
    {
        return Plugin_Continue; // Auto-dano permitido
    }

    if (IsValidClient(attacker))
    {
        return Plugin_Handled; // Bloqueia dano de outros jogadores
    }

    return Plugin_Continue;
}

public Action Command_ToggleNoDamage(int client, int args)
{
    g_NoDamageEnabled = !g_NoDamageEnabled;

    char status[32];
    Format(status, sizeof(status), g_NoDamageEnabled ? "ATIVADA" : "DESATIVADA");

    PrintToChatAll("[NoDamage] Proteção contra dano entre jogadores está agora: %s", status);

    return Plugin_Handled;
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client));
}
