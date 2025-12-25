/*----------------------------------------------------------------------------*-
					===========================
					Y Server inclui - Núcleo INI
					===========================
Descrição:
	Lê o arquivo INI e também exporta diversas funções para outras "classes" para
	leitura fácil de arquivos de dados ali.
Jurídico:
	Versão: MPL 1.1
	
	O conteúdo deste arquivo está sujeito à Licença Pública Mozilla.
	1.1 (a "Licença"); você não pode usar este arquivo, exceto em conformidade com
	a Licença. Você pode obter uma cópia da Licença em
	http://www.mozilla.org/MPL/
	
	O software distribuído sob a Licença é distribuído "TAL COMO ESTÁ".
	SEM GARANTIA DE QUALQUER TIPO, expressa ou implícita. Consulte a Licença.
	para a linguagem específica que rege os direitos e limitações ao abrigo do
	Licença.
	
	O código original inclui as informações do script SA:MP.
	
	O desenvolvedor inicial do código original é Alex "Y_Less" Cole.
	Partes criadas pelo desenvolvedor inicial são protegidas por direitos autorais (C) 2008.
	Desenvolvedor original. Todos os direitos reservados.
	
	Colaboradores:
		ZeeX, legal
	
	Obrigado:
		Peter, Cam - Suporte.
		ZeeX - Conversas muito produtivas.
		koolk - Código IsPlayerinAreaEx.
		TheAlpha - Tradução para dinamarquês.
		peixe-pão - tradução alemã.
		Fireburn - Tradução para o holandês.
		yom - Tradução para o francês.
		50 centavos - Tradução para polonês.
		Zamaroht - Tradução para o espanhol.
		Dracoblue, sintaxe, mabako, Xtreme, outros codificadores - Produzindo outros modos
			Para que eu possa me esforçar para ser melhor.
		Pixels^ - Executando XScripters, onde a ideia nasceu.
		Matite - Me importunando para que eu a libere e a esteja usando.
	
	Um agradecimento muito especial a:
		Thiadmer - PEÃO.
		Kye/Kalcor - SA:MP.
		SA:MP Equipe passado, presente e futuro - SA:MP.
Versão:
	1.0
Registro de alterações:
	08/09/10:
		Iniciamos a adição de compatibilidade com os plugins sscanf e file.
		Adição de dados sem tags no início de um arquivo (compatível com dini).
		Adicionada nova sintaxe INI:file[tag]().
		Adicionadas opções para o carregamento de arquivos padrão.
		Corrigidos erros na configuração padrão de carregamento de arquivos.
		Modificado para funcionar de forma independente.
	20/02/08:
		Adicionada a entrada INI_RemoveEntry.
	18/08/07:
		Corrigido um bug na leitura de identificadores que começavam com uma tag (ex.: nomes).
		Adicionada leitura de arquivos locais para transmissões que não sejam para todo o servidor.
		Adicionada a opção de passagem de tags em vez de funções baseadas em tags.
		Aumentamos o tamanho padrão do pool.
	30/07/07:
		Adicionada a criação automática de arquivos inexistentes.
	13/07/07:
		Corrigido o problema de escrita em INI, que agora funciona corretamente.
		Adicionado suporte para linhas em branco em arquivos INI de forma eficiente e rápida.
	25/06/07:
		Opções de gravação de arquivos alteradas para usar listas.
		Adicionada a sobrescrita de buffer para atualização de valores.
	24/06/07:
		Adicionadas opções de gravação de arquivos.
	21/06/07:
		Adicionada a variável INI_NEW_LINE para futuras funções de escrita.
	20/06/07:
		Adicionada a possibilidade de um parâmetro opcional nos dados de transmissão.
	15/04/07:
		Atualizado para incluir mais espaços em branco.
		Adicionado código de comentário INI.
		Adicionado suporte para entradas sem valor.
		Extração de entradas modificada para usar o parâmetro de localização do final do nome.
		A função INI_GetTagName foi removida e agora é executada através da função INI_GetEntryName.
	14/04/07:
		Documentação do cabeçalho atualizada com mais informações além do changelog.
	24/03/07:
		Primeira versão.
Funções:
	Público:
		-
	Essencial:
		-
	Estoque:
		INI_Load - Carrega um arquivo INI usando recursos padrão.
		INI_ParseFile - Carrega um arquivo como um arquivo INI e distribui os dados.
		INI_GetEntryName - Obtém o nome de um item INI.
		INI_GetEntryText - Obtém o valor de um item INI.
		INI_Open – Abre um INI para escrita.
		INI_Close - Fecha um arquivo INI que está sendo gravado.
		INI_SetTag - Define um subtítulo em um arquivo INI para gravações subsequentes.
		INI_WriteString - Escreve uma string em um arquivo INI.
		INI_WriteInt - Escreve um número inteiro em um arquivo INI.
		INI_WriteFloat - Escreve um número de ponto flutuante em um arquivo INI.
		INI_WriteHex - Escreve um valor hexadecimal em um arquivo INI.
		INI_WriteBin - Escreve um arquivo binário em um arquivo INI.
		INI_WriteBool - Escreve um valor booleano em um arquivo INI.
		INI_RemoveEntry - Remove uma entrada de um arquivo.
	Estático:
		INI_WriteBuffer - Escreve o buffer de um arquivo INI no arquivo.
		INI_AddToBuffer – Adiciona uma string a um buffer INI.
	Em linha:
		INI_Int - analisa uma entrada INI inteira.
		INI_Float - analisa uma entrada INI flutuante.
		INI_Hex - analisa uma entrada INI hexadecimal.
		INI_Bin - analisa uma entrada INI binária.
		INI_Bool - analisa uma entrada INI binária.
		INI_String - analisa uma entrada INI de string.
	API:
		-
Retornos de chamada:
	-
Definições:
	MAX_INI_TAG - Comprimento máximo de um tagname INI.
	MAX_INI_ENTRY_NAME - Comprimento máximo do nome de uma entrada INI.
	MAX_INI_ENTRY_TEXT - Comprimento máximo do valor das entradas de um arquivo INI.
	MAX_INI_LINE - Comprimento máximo de uma linha em um arquivo.
	INI_NEW_LINE - String para novas linhas.
	INI_MAX_WRITES - Número máximo de arquivos abertos simultaneamente para escrita.
	MAX_INI_TAGS - Número de tags que o buffer pode armazenar dados simultaneamente.
Enums:
	E_INI_WRITE - Armazenamento para entradas a serem gravadas.
	E_INI_TAGS - Dados para tags com dados.
Macros:
	INI_Parse – Cabeçalho para funções de análise ini.
Etiquetas:
	INI - Identificador de um arquivo INI que está sendo gravado.
Variáveis:
	Global:
		-
	Estático:
		YSI_g_sINIWriteBuffer - Dados básicos a serem gravados.
		YSI_g_sINIWritePos - Próximo slot para escrita.
		YSI_g_sINITagPos - Próximo slot ao qual adicionar uma tag.
		YSI_g_sINICurrentTag - Ponteiro para a tag na qual a escrita foi feita.
		YSI_g_sINIWriteTag - Dados para tags,
		YSI_g_sINIWriteFile - Arquivo atual sendo gravado.
Comandos:
	-
Opções de compilação:
	-
Operadores:
	-
-*----------------------------------------------------------------------------*/

// A leitura de arquivos INI não é distribuída. A leitura de arquivos de usuário pode ser, embora eu
// Duvido.

#include <YSI\internal\y_version>

//#tryinclude <sscanf>

#include <YSI\y_utils>
#include <YSI\y_bit>
#include <YSI\y_debug>

#if !defined MAX_INI_TAG
	#define MAX_INI_TAG (16)
#fim

#if !defined MAX_INI_ENTRY_NAME
	#define MAX_INI_ENTRY_NAME (32)
#fim

#if !defined MAX_INI_ENTRY_TEXT
	#define MAX_INI_ENTRY_TEXT 128
#fim

#define MAX_INI_LINE (MAX_INI_ENTRY_NAME + MAX_INI_ENTRY_TEXT + 32)

#define INI_NO_FILE (INI:-1)

#if !defined INI_NEW_LINE
	#define INI_NEW_LINE "\r\n"
#fim

#if !defined INI_MAX_WRITES
	// Duvido que muitas pessoas usem a função de múltiplos arquivos .ini.
	#define INI_MAX_WRITES (2)
#fim

#if !defined INI_BUFFER_SIZE
	#define INI_BUFFER_SIZE (64)
#fim

/*#if INI_BUFFER_SIZE <= 32
	#define INI_BUFFER_BITS 2
#outro
	#define INI_BUFFER_BITS Bit_Bits(INI_BUFFER_SIZE)
#fimse*/

#if !defined MAX_INI_TAGS
	#define MAX_INI_TAGS 3
/*#outro
	#if MAX_INI_TAGS > 32
		#erro O código atual suporta apenas até 32 tags de buffer.
	#fimse*/
#fim

#define MAX_INI_STRING (64)

enum E_INI_WRITE
{
	E_INI_WRITE_NAME[MAX_INI_ENTRY_NAME],
	E_INI_WRITE_TEXT[MAX_INI_ENTRY_TEXT],
	E_INI_WRITE_NEXT
}

enum E_INI_TAGS
{
	E_INI_TAGS_NAME[caractere MAX_INI_TAG],
	E_INI_TAGS_START,
	E_INI_TAGS_ÚLTIMO
}

estoque estático
	YSI_g_sINIWriteBuffer[INI_MAX_WRITES][INI_BUFFER_SIZE][E_INI_WRITE],
	YSI_g_sINIWritePos[INI_MAX_WRITES],
	YSI_g_sINITagPos[INI_MAX_WRITES],
	YSI_g_sINICurrentTag[INI_MAX_WRITES],
	YSI_g_sINIWriteTag[INI_MAX_WRITES][MAX_INI_TAGS][E_INI_TAGS],
	YSI_g_sINIWriteFile[INI_MAX_WRITES][128];

#define INI_Parse(%1,%2) \
	encaminhar @INI_%1_%2(nome[], valor[]); \
	@INI_%1_%2(nome[], valor[])

#define INI:%0[%1](%2) \
	encaminhar @INI_%0_%1(%2); \
	@INI_%0_%1(%2)

#se definido _inc_sscanf && 0
	/*------------------------------------------------------------------------*-
	Função:
		INI_Int
	Parâmetros:
		nome[] - Nome do identificador textual INI.
		Função - Função a ser chamada com valor inteiro.
	Retornar:
		função().
	Notas:
		-
	-*------------------------------------------------------------------------*/
	
	#define INI_Int(%1,%2) \
		if(!strcmp((%1),name,true)&&!sscanf(value,"d",%2))return;
		//if(!strcmp(){%2=floatstr(value);return;}
		//if (!strcmp((%1), name, true)) return %2(strval(value))
	
	/*------------------------------------------------------------------------*-
	Função:
		INI_Float
	Parâmetros:
		nome[] - Nome do identificador textual INI.
		Função - Função a ser chamada com valor float.
	Retornar:
		função().
	Notas:
		-
	-*------------------------------------------------------------------------*/
	
	#define INI_Float(%1,%2) \
		if(!strcmp((%1),name,true)&&!sscanf(value,"f",%2))return;
		//if (!strcmp((%1), name, true)) return %2(floatstr(value))
	
	/*------------------------------------------------------------------------*-
	Função:
		INI_Hex
	Parâmetros:
		nome[] - Nome do identificador textual INI.
		Função - Função a ser chamada com valor hexadecimal.
	Retornar:
		função().
	Notas:
		-
	-*------------------------------------------------------------------------*/
	
	#define INI_Hex(%1,%2) \
		if(!strcmp((%1),name,true)&&!sscanf(value,"h",%2))return;
		//if (!strcmp((%1), name, true)) return %2(hexstr(value))
	
	/*------------------------------------------------------------------------*-
	Função:
		INI_Bin
	Parâmetros:
		nome[] - Nome do identificador textual INI.
		Função - Função a ser chamada com valor binário.
	Retornar:
		função().
	Notas:
		-
	-*------------------------------------------------------------------------*/
	
	#define INI_Bin(%1,%2) \
		if(!strcmp((%1),name,true)&&!sscanf(value,"l",%2))return;
		//if (!strcmp((%1), name, true)) return %2(binstr(value))
	
	/*------------------------------------------------------------------------*-
	Função:
		INI_String
	Parâmetros:
		nome[] - Nome do identificador textual INI.
		Função - Função a ser chamada com valor de string.
	Retornar:
		função().
	Notas:
		-
	-*------------------------------------------------------------------------*/
	
	#define INI_String(%1,%2,%3) \
		if(!strcmp((%1),name,true)&&!sscanf(value,"s["#%3"]",%2))return;
		//if (!strcmp((%1), name, true)) return %2(value)
#outro
	#define INI_Int(%1,%2) \
		if(!strcmp((%1),name,true))return %2=strval(value)
	
	#define INI_Float(%1,%2) \
		if(!strcmp((%1),name,true))return _:(%2=floatstr(value))
	
	#define INI_Hex(%1,%2) \
		if(!strcmp((%1),name,true))return %2=hexstr(value)
	
	#define INI_Bin(%1,%2) \
		if(!strcmp((%1),name,true))return %2=binstr(value)
	
	#define INI_Bool(%1,%2) \
		if(!strcmp((%1),name,true))return %2=boolstr(value)
	
	#define INI_String(%1,%2,%3) \
		if(!strcmp((%1),name,true))return strcpy(%2,value,%3)
#fim

/*----------------------------------------------------------------------------*-
Função:
	INI_GetEntryName
Parâmetros:
	origem - A string da qual você deseja obter o nome da entrada.
	dest - O local onde você deseja armazenar o nome da entrada.
Retornar:
	booleano: O nome foi encontrado corretamente.
Notas:
	-
-*----------------------------------------------------------------------------*/

estoque bool:INI_GetEntryName(source[], dest[], &i)
{
	novo
		j;
	enquanto (source[j] && source[j] <= ' ') j++;
	i = j;
	enquanto (source[i] > ' ' && source[i] != '=') i++;
	se (i == j) retorne falso;
	i -= j;
	memcpy(dest, source, j, i * 4, MAX_INI_ENTRY_NAME);
	dest[i] = '\0';
	retornar verdadeiro;
}

/*----------------------------------------------------------------------------*-
Função:
	INI_GetEntryText
Parâmetros:
	Fonte - A string da qual você deseja obter uma entrada.
	dest - O local onde você deseja armazenar a entrada.
Retornar:
	-
Notas:
-*----------------------------------------------------------------------------*/

estoque INI_GetEntryText(origem[], destino[], i)
{
	enquanto (source[i] && (source[i] <= ' ' || source[i] == '=')) i++;
	dest[0] = 1;
	dest[1] = '\0';
	se (!source[i]) retornar;
	strcpy(dest, source[i], MAX_INI_ENTRY_TEXT);
}

/*----------------------------------------------------------------------------*-
Função:
	Arquivo INI_ParseFile
Parâmetros:
	filename[] - O arquivo a ser carregado.
	remoteFormat[] - A string de formato para gerar a função remota.
		Passe os dados assim que forem carregados.
	bool:bFileFirst - A ordem dos parâmetros remoteFormat.
	bool:bExtra - Enviar dados adicionais.
	extra - Dados adicionais a serem enviados.
	bLocal - Chama funções locais em vez de globais.
	bPassTag - Passe a tag como um parâmetro extra, não o nome da função.
Retornar:
	-
Notas:
	bFileFirst define a ordem e a inclusão dos possíveis formatos remotos.
	parâmetros. Se verdadeiro, o formato adicionará primeiro o nome do arquivo e depois o
	A tag atual; se falsa, a ordem será invertida. Isso também pode ser usado.
	Para excluir um ou outro do nome da função, definindo o valor necessário.
	parâmetro a ser inserido primeiro e depois apenas um %s no formato
	sting. A ordem padrão é tag primeiro para compatibilidade de idiomas.
-*----------------------------------------------------------------------------*/

estoque bool:INI_ParseFile(filename[], remoteFormat[], bool:bFileFirst = false, bool:bExtra = false, extra = 0, bool:bLocal = true, bool:bPassTag = false)
{
	novo
		Arquivo:f;
	se (!(f = fopen(filename, io_read))) retorne falso;
	novo
		linha[MAX_INI_LINE],
		tagName[MAX_INI_STRING],
		função[MAX_INI_STRING],
		comentário,
		pos;
	// Remove a extensão do nome do arquivo.
	comentário = chrfind('.', nome_do_arquivo);
	se (comentário != -1) nome_do_arquivo[comentário] = '\0';
	// Agora, reduza a lista apenas ao nome do arquivo, sem o caminho.
	enquanto (comentário != -1)
	{
		se (nome_do_arquivo[comentário] == '\\' || nome_do_arquivo[comentário] == '/')
		{
			//strcpy(filename, filename[comment + 1], MAX_INI_STRING);
			++comentário;
			novo
				i = 0;
			enquanto ((nome_do_arquivo[i] = nome_do_arquivo[comentário + i]))
			{
				++i;
			}
			quebrar;
		}
		--comentário;
	}
	// Define o valor padrão da tag.
	se (bFileFirst)
	{
		format(função, sizeof(função), formatoRemoto, nomeDoArquivo, "");
	}
	outro
	{
		format(função, sizeof(função), formatoRemoto, "", nomeDoArquivo);
	}
	// Agora leia todos os dados.
	enquanto (fread(f, linha))
	{
		StripNL(linha);
		se (!linha[0]) continue;
		novo
			stringIdent[MAX_INI_ENTRY_NAME];
		comentário = chrfind(';', linha);
		se (comentário != -1)
		{
			linha[comentário] = '\0';
		}
		se (!INI_GetEntryName(linha, stringIdent, pos))
		{
			continuar;
		}
		se (stringIdent[0] == '[' && (comment = chrfind(']', stringIdent)) != -1 && !stringIdent[comment + 1])
		{
			// Obtive uma tag, atualize a função a ser chamada.
			stringIdent[comment] = '\0';
			se (bFileFirst)
			{
				format(função, sizeof(função), formatoRemoto, nomeArquivo, stringIdent[1]);
			}
			outro
			{
				format(função, sizeof(função), formatoRemoto, stringIdent[1], nomeDoArquivo);
			}
			// Ignore verificações complexas sempre que possível.
			se (bLocal && funcidx(função) == -1)
			{
				função[0] = '\0';
			}
			senão se (bPassTag)
			{
				strcpy(tagName, stringIdent[1], MAX_INI_STRING);
			}
		}
		senão se (função[0])
		{
			novo
				stringText[MAX_INI_ENTRY_TEXT];
			INI_GetEntryText(linha, stringText, posição);
			// Leia um valor e distribua-o conforme necessário.
			se (bLocal)
			{
				se (bExtra)
				{
					se (bPassTag)
					{
						CallLocalFunction(function, "isss", extra, tagName, stringIdent, stringText);
					}
					outro
					{
						CallLocalFunction(function, "iss", extra, stringIdent, stringText);
					}
				}
				outro
				{
					se (bPassTag)
					{
						CallLocalFunction(function, "sss", tagName, stringIdent, stringText);
					}
					outro
					{
						ChamarFunçãoLocal(função, "ss", stringIdent, stringText);
					}
				}
			}
			outro
			{
				se (bExtra)
				{
					se (bPassTag)
					{
						CallRemoteFunction(function, "isss", extra, tagName, stringIdent, stringText);
					}
					outro
					{
						CallRemoteFunction(function, "iss", extra, stringIdent, stringText);
					}
				}
				outro
				{
					se (bPassTag)
					{
						CallRemoteFunction(function, "sss", tagName, stringIdent, stringText);
					}
					outro
					{
						CallRemoteFunction(function, "ss", stringIdent, stringText);
					}
				}
			}
		}
	}
	fclose(f);
	retornar verdadeiro;
}

/*----------------------------------------------------------------------------*-
Função:
	INI_Carregar
Parâmetros:
	filename[] - O arquivo a ser carregado.
	bool:bExtra - Enviar dados adicionais.
	extra - Dados adicionais a serem enviados.
	bLocal - Chama funções locais em vez de globais.
Retornar:
	Arquivo INI_ParseFile
Notas:
	Wrapper para INI_ParseFile para usar recursos da API padrão, permitindo que as pessoas possam
	Preocupe-se ainda menos. Projetado para uso com INI_Parse.
-*----------------------------------------------------------------------------*/

estoque bool:INI_Load(filename[], bool:bExtra = false, extra = 0, bool:bLocal = true)
{
	return INI_ParseFile(nome do arquivo, "@INI_%s_%s", verdadeiro, bExtra, extra, bLocal, falso);
}

/*----------------------------------------------------------------------------*-
Função:
	INI_Abrir
Parâmetros:
	filename[] - Arquivo INI a ser aberto.
Retornar:
	INI - identificador do arquivo ou INI_NO_FILE.
Notas:
	Na verdade, não abre o arquivo, apenas inicia um novo buffer, se possível.
-*----------------------------------------------------------------------------*/

estoque INI:INI_Open(nome do arquivo[])
{
	novo
		eu;
	para (i = 0; i < INI_MAX_WRITES; i++)
	{
		se (!YSI_g_sINIWriteFile[i][0]) interrompa;
	}
	se (i == INI_MAX_WRITES)
	{
		retornar INI_NO_FILE;
	}
	strcpy(YSI_g_sINIWriteFile[i], nome do arquivo, sizeof (YSI_g_sINIWriteFile[]));
	YSI_g_sINIWritePos[i] = 0;
	YSI_g_sINITagPos[i] = 0;
	// Redefinir tags.
	YSI_g_sINICurrentTag[i] = 0;
	YSI_g_sINIWriteTag[i][0][E_INI_TAGS_NAME][0] = '\0';
	YSI_g_sINIWriteTag[i][0][E_INI_TAGS_START] = -1;
/* se (!fexist(nome do arquivo))
	{
		novo
			Arquivo:fHnd = fopen(nome_do_arquivo, io_write);
		se (fHnd)
		{
			fclose(fHnd);
		}
		C:1(else printf("*** Erro interno: Não foi possível criar o arquivo de destino"););
	}*/
	retornar INI:i;
}

/*----------------------------------------------------------------------------*-
Função:
	INI_Fechar
Parâmetros:
	INI:arquivo - Identificador do arquivo INI a ser fechado.
Retornar:
	-
Notas:
	Grava quaisquer dados de buffer pendentes no arquivo e encerra o fluxo.
-*----------------------------------------------------------------------------*/

estoque INI_Close(INI:arquivo)
{
	se (YSI_g_sINIWritePos[_:arquivo]) INI_WriteBuffer(arquivo);
	YSI_g_sINIWriteFile[_:file][0] = '\0';
}

/*----------------------------------------------------------------------------*-
Função:
	INI_SetTag
Parâmetros:
	INI:arquivo - Identificador do arquivo INI no qual será feita a escrita.
	tag[] - Nome da nova subseção do arquivo para onde os dados subsequentes serão gravados.
Retornar:
	-
Notas:
	Define um novo cabeçalho de seção [tag]. Os dados subsequentes são gravados abaixo dele.
	cabeçalho. Usa listas para troca constante de tags e verifica se a tag não
	já existem.
-*----------------------------------------------------------------------------*/

estoque INI_SetTag(INI:arquivo, tag[])
{
	if (arquivo < INI:0 || arquivo >= INI:INI_MAX_WRITES) retornar;
	novo
		pos = YSI_g_sINITagPos[_:arquivo];
	para (novo i = 0; i < pos; i++)
	{
		se (YSI_g_sINIWriteTag[_:file][i][E_INI_TAGS_NAME][0] && !strcmp(tag, YSI_g_sINIWriteTag[_:file][i][E_INI_TAGS_NAME], true))
		{
			YSI_g_sINICurrentTag[_:arquivo] = i;
			retornar;
		}
	}
	// Permitir dados não etiquetados (não tenho certeza de como isso será recebido...).
	/*if (pos == 0 && YSI_g_sINIWriteTag[_:file][0][E_INI_TAGS_START] != -1)
	{
		++pos;
		++YSI_g_sINITagPos[_:arquivo];
	}*/
	se (pos >= MAX_INI_TAGS)
	{
		se (!INI_WriteBuffer(arquivo)) retorne;
		// Laço.
		pos = 0;
	}
	//strcpy(YSI_g_sINIWriteTag[_:file][pos][E_INI_TAGS_NAME], tag, MAX_INI_TAG);
	strpack(YSI_g_sINIWriteTag[_:file][pos][E_INI_TAGS_NAME], tag, MAX_INI_TAG);
	YSI_g_sINIWriteTag[_:file][pos][E_INI_TAGS_START] = -1;
	YSI_g_sINICurrentTag[_:arquivo] = pos;
	++YSI_g_sINITagPos[_:arquivo];
}

/*----------------------------------------------------------------------------*-
Função:
	INI_AdicionarAoBuffer
Parâmetros:
	INI:arquivo - Arquivo INI para escrita.
	nome[] - Nome dos dados a serem gravados.
	data[] - Dados a serem gravados.
Retornar:
	-
Notas:
	Primeiro, verifica se o nome já não existe no cabeçalho da tag atual.
	E se houver, sobrescreve o valor atual. Caso contrário, verifica se há espaço.
	no buffer para escrever e limpa o buffer se não estiver vazio. Finalmente, salva o
	Os dados são armazenados no buffer para serem gravados quando necessário e os dados são adicionados ao...
	Lista relevante para inclusão de tags.
-*----------------------------------------------------------------------------*/

estoque estático INI_AddToBuffer(INI:arquivo, nome[], dados[])
{
	if (arquivo < INI:0 || arquivo >= INI:INI_MAX_WRITES)
	{
		retornar 0;
	}
	if (!YSI_g_sINITagPos[_:arquivo])
	{
		// Dados sem tags.
		YSI_g_sINITagPos[_:file] = 1;
		YSI_g_sINIWriteTag[_:arquivo][0][E_INI_TAGS_START] = -1;
		YSI_g_sINIWriteTag[_:file][0][E_INI_TAGS_NAME][0] = 0;
	}
	novo
		pos = YSI_g_sINIWritePos[_:arquivo],
		tmptag = YSI_g_sINICurrentTag[_:arquivo],
		início = YSI_g_sINIWriteTag[_:arquivo][tmptag][E_INI_TAGS_START];
	enquanto (início != -1)
	{
		se (!strcmp(nome, YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_NAME], verdadeiro))
		{
			strcpy(YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_TEXT], data, MAX_INI_ENTRY_TEXT);
			//strpack(YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_TEXT], data, MAX_INI_ENTRY_TEXT);
			retornar 1;
		}
		início = YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_NEXT];
	}
	se (pos >= INI_BUFFER_SIZE)
	{
		se (!INI_WriteBuffer(arquivo))
		{
			retornar 0;
		}
		INI_SetTag(arquivo, YSI_g_sINIWriteTag[_:arquivo][tmptag][E_INI_TAGS_NAME]);
		pos = 0;
	}
	novo
		curtag = YSI_g_sINICurrentTag[_:arquivo];
	if (YSI_g_sINIWriteTag[_:file][curtag][E_INI_TAGS_START] == -1)
	{
		YSI_g_sINIWriteTag[_:file][curtag][E_INI_TAGS_START] = pos;
	}
	outro
	{
		YSI_g_sINIWriteBuffer[_:file][YSI_g_sINIWriteTag[_:file][curtag][E_INI_TAGS_LAST]][E_INI_WRITE_NEXT] = pos;
	}
	strcpy(YSI_g_sINIWriteBuffer[_:file][pos][E_INI_WRITE_NAME], name, MAX_INI_ENTRY_NAME);
	//strpack(YSI_g_sINIWriteBuffer[_:file][pos][E_INI_WRITE_NAME], name, MAX_INI_ENTRY_NAME);
	strcpy(YSI_g_sINIWriteBuffer[_:file][pos][E_INI_WRITE_TEXT], data, MAX_INI_ENTRY_TEXT);
	YSI_g_sINIWriteBuffer[_:file][pos][E_INI_WRITE_NEXT] = -1;
	YSI_g_sINIWriteTag[_:file][curtag][E_INI_TAGS_LAST] = pos;
	YSI_g_sINIWritePos[_:arquivo]++;
	retornar 1;
}

/*----------------------------------------------------------------------------*-
Função:
	INI_RemoverEntrada
Parâmetros:
	INI:arquivo - Arquivo para escrita.
	nome[] - Item a ser removido.
Retornar:
	-
Notas:
	Wrapper para INI_AddToBuffer para remoção de dados.
-*----------------------------------------------------------------------------*/

estoque INI_RemoveEntry(INI:arquivo, nome[])
{
	estático
		sData[2] = {-1, 0};
	INI_AddToBuffer(arquivo, nome, sData);
}

/*----------------------------------------------------------------------------*-
Função:
	INI_WriteString
Parâmetros:
	INI:arquivo - Arquivo para escrita.
	nome[] - Nome dos dados.
	dados[] - Dados.
Retornar:
	-
Notas:
	Wrapper para INI_AddToBuffer para strings.
-*----------------------------------------------------------------------------*/

estoque INI_WriteString(INI:arquivo, nome[], dados[])
{
	INI_AddToBuffer(arquivo, nome, dados);
}

/*----------------------------------------------------------------------------*-
Função:
	INI_WriteInt
Parâmetros:
	INI:arquivo - Arquivo para escrita.
	nome[] - Nome dos dados.
	Dados - Dados inteiros.
Retornar:
	-
Notas:
	Wrapper para INI_AddToBuffer para números inteiros.
-*----------------------------------------------------------------------------*/

estoque INI_WriteInt(INI:arquivo, nome[], dados)
{
	novo
		str[12];
	valstr(str, dados);
	INI_AddToBuffer(arquivo, nome, str);
}

/*----------------------------------------------------------------------------*-
Função:
	INI_WriteHex
Parâmetros:
	INI:arquivo - Arquivo para escrita.
	nome[] - Nome dos dados.
	Dados - Dados hexadecimais.
Retornar:
	-
Notas:
	Wrapper para INI_AddToBuffer para que números inteiros sejam escritos como valores hexadecimais.
-*----------------------------------------------------------------------------*/

estoque INI_WriteHex(INI:arquivo, nome[], dados)
{
	constante estática
		sc_values[] = "0123456789ABCDEF";
	novo
		str[11],
		i = 9;
	fazer
	{
		str[i--] = sc_values{dados & 0x0F};
		dados >>>= 4;
	}
	enquanto (dados);
	str[i--] = 'x';
	str[i] = '0';
	INI_AddToBuffer(arquivo, nome, str[i]);
}

/*----------------------------------------------------------------------------*-
Função:
	INI_WriteBin
Parâmetros:
	INI:arquivo - Arquivo para escrita.
	nome[] - Nome dos dados.
	Dados - Dados binários.
Retornar:
	-
Notas:
	Wrapper para INI_AddToBuffer, que permite escrever números inteiros como valores binários.
-*----------------------------------------------------------------------------*/

estoque INI_WriteBin(INI:arquivo, nome[], dados)
{
	// Processa quatro valores simultaneamente para maior velocidade. Isso utiliza uma string compactada e a descompacta.
	// para que possamos escrever quatro valores de uma só vez rapidamente.
	constante estática
		sc_values[] = "0000000100100011010001010110011110001001101010111100110111101111";
	novo
		str[35],
		i = 10;
	fazer
	{
		str[--i] = sc_values[data & 0x0F];
		dados >>>= 4;
	}
	enquanto (dados);
	// Converter os valores coalescidos em valores individuais.
	strunpack(str[i], str[i], 33);
	str[--i] = 'b';
	str[--i] = '0';
	INI_AddToBuffer(arquivo, nome, str[i]);
}

/*----------------------------------------------------------------------------*-
Função:
	INI_WriteBool
Parâmetros:
	INI:arquivo - Arquivo para escrita.
	nome[] - Nome dos dados.
	Dados - Dados booleanos.
Retornar:
	-
Notas:
	Wrapper para INI_AddToBuffer para booleanos.
-*----------------------------------------------------------------------------*/

estoque INI_WriteBool(INI:arquivo, nome[], bool:dados)
{
	se (dados)
	{
		INI_AddToBuffer(arquivo, nome, "verdadeiro");
	}
	outro
	{
		INI_AddToBuffer(arquivo, nome, "falso");
	}
}

/*----------------------------------------------------------------------------*-
Função:
	INI_WriteFloat
Parâmetros:
	INI:arquivo - Arquivo para escrita.
	nome[] - Nome dos dados.
	Float:dados - Dados de ponto flutuante.
	Precisão - número de casas decimais a serem escritas.
Retornar:
	-
Notas:
	Wrapper para INI_AddToBuffer para números de ponto flutuante. Usa código personalizado em vez de
	format() é mais rápido para algo simples como isso.
-*----------------------------------------------------------------------------*/

estoque INI_WriteFloat(INI:arquivo, nome[], Float:dados, precisão = 6)
{
	novo
		str[32];
	format(str, sizeof (str), "%.*f", accuracy, data);
	INI_AddToBuffer(arquivo, nome, str);
}

/*----------------------------------------------------------------------------*-
Função:
	INI_WriteBuffer
Parâmetros:
	INI:arquivo - Fluxo INI para escrita em arquivo.
Retornar:
	Sucesso/fracasso.
Notas:
	Abre o arquivo necessário para leitura e um arquivo temporário para leitura/gravação.
	percorre todo o arquivo, lendo todos os dados contidos nele. Se encontrar uma tag.
	linha ([nome_da_tag]) ele despeja quaisquer dados não gravados da última tag (se houver)
	era um) e começa a processar a nova etiqueta. Enquanto uma etiqueta está sendo processada.
	Cada linha é comparada com os novos dados NÃO ESCRITOS para essa tag no
	buffer, se forem iguais, ele grava os novos dados em vez dos antigos (ele também grava).
	quaisquer comentários que estivessem após os dados na linha original (back), caso contrário
	reescreve a linha original.
	
	Assim que todos os novos dados forem gravados no arquivo temporário, quaisquer tags que ainda não tenham sido incluídas serão removidas.
	foram processados ​​(ou seja, não foram encontrados no arquivo original)
	gravado no arquivo temporário juntamente com todos os seus dados. O arquivo original é
	Em seguida, o arquivo foi destruído e reaberto, e todos os dados foram copiados do arquivo temporário.
	ao arquivo original recém-aberto, fechado e salvo.
-*----------------------------------------------------------------------------*/

estoque estático INI_WriteBuffer(INI:arquivo)
{
	se (_:arquivo < 0 || _:arquivo >= INI_MAX_WRITES) retorne 0;
	novo
		//Arquivo:buffer = fopen("_temp_ysi_user_file_.ysi", io_write),
		Arquivo:buffer = ftemp(),
		Arquivo:fonte = fopen(YSI_g_sINIWriteFile[_:arquivo], io_read);
	se (buffer)
	{
		novo
			linha[MAX_INI_LINE],
			BitArray:ler<INI_BUFFER_SIZE>, //:ler[INI_BUFFER_BITS],
			escrita = 0,
			//Bit:tagsescrito,
			BitArray: tags escritas<MAX_INI_TAGS>,
			tagpos = YSI_g_sINITagPos[_:arquivo],
			início = -1,
			em branco;
		se (fonte)
		{
			// Escrever dados sem tags.
			se (!YSI_g_sINIWriteTag[_:file][0][E_INI_TAGS_NAME][0])
			{
				início = YSI_g_sINIWriteTag[_:arquivo][0][E_INI_TAGS_START];
				// Será -1 se não houver dados sem tag.
				se (início != -1)
				{
					escrita = 1;
					Bit_Set(tagswritten, 0, true);
				}
			}
			enquanto (fread(fonte, linha))
			{
				novo
					pos = 1;
				para (novo i = 0; linha[i]; i++)
				{
					se (linha[i] == ';')
					{
						goto INI_WriteBuffer_cont1;
					}
					senão se (linha[i] > ' ')
					{
						// Verificar se a linha não está em branco.
						pos = 0;
						quebrar;
					}
				}
				se (pos)
				{
					em branco++;
					continuar;
				}
				se (linha[0] == '[' && (pos = chrfind(']', linha)) != -1 && fim da linha(linha, pos + 1))
				{
					pos--;
					escrita = 0;
					novo
						formulário[MAX_INI_LINE];
					// Chegou a uma nova tag - limpe o restante da tag anterior.
					enquanto (início != -1)
					{
						se (!Bit_GetBit(leitura, início))
						{
							se (YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_TEXT][0] != -1)
							{
								format(form, sizeof (form), "%s = %s" INI_NEW_LINE, YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_NAME], YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_TEXT]);
								fwrite(buffer, formulário);
							}
							Bit_Set(leitura, início, verdadeiro);
						}
						início = YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_NEXT];
					}
					while (blank--) fwrite(buffer, INI_NEW_LINE);
					em branco = 0;
					// Observe o início da nova tag.
					para (novo j = 0; j < tagpos; j++)
					{
						//if (!Bit_Get(tagswritten, j) && !YSI_g_sINIWriteTag[_:file][j][E_INI_TAGS_NAME][pos] && !strcmp(YSI_g_sINIWriteTag[_:file][j][E_INI_TAGS_NAME], line[1], true, pos))
						se (!Bit_Get(tagswritten, j) && !strcmp(YSI_g_sINIWriteTag[_:file][j][E_INI_TAGS_NAME], line[1], true, pos))
						{
							escrita = 1;
							início = YSI_g_sINIWriteTag[_:arquivo][j][E_INI_TAGS_START];
							//tagswritten |= Bit:(1 << j);
							Bit_Set(tagswritten, j, true);
							quebrar;
						}
					}
				}
				senão se (escrita)
				{
					novo
						nome[MAX_INI_ENTRY_NAME],
						temperatura,
						liststart = início;
					INI_GetEntryName(linha, nome, temp);
					pos = chrfind(';', linha, temp);
					while (blank--) fwrite(buffer, INI_NEW_LINE);
					em branco = 0;
					enquanto (início != -1)
					{
						se (!Bit_GetBit(read, start) && !strcmp(name, YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_NAME]))
						{
							Bit_Set(leitura, início, verdadeiro, INI_BUFFER_SIZE);
							// Exclua a entrada atual do arquivo, conforme
							// Nosso pedido.
							se (YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_TEXT][0] == -1)
							{
								// Não é possível usar "continuar", pois estamos em um ambiente interno
								// laço.
								goto INI_WriteBuffer_cont2;
							}
							se (pos != -1)
							{
								format(linha, sizeof (linha), "%s = %s %s", nome, YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_TEXT], linha[pos]);
							}
							outro
							{
								format(linha, sizeof (linha), "%s = %s" INI_NEW_LINE, nome, YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_TEXT]);
							}
							//início = -1;
							quebrar;
						}
						outro
						{
							início = YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_NEXT];
						}
					}
					/*se (início == -1)
					{
						// Não foi encontrado.
						início = strlen(linha);
						se (linha[início - 1] > ' ')
						{
							strcat(linha, INI_NEW_LINE);
						}
					}*/
					início = listastart;
				}
				INI_WriteBuffer_cont1:
				fwrite(buffer, linha);
				INI_WriteBuffer_cont2:
			}
			// Escreva quaisquer dados deste grupo de tags que não estejam no arquivo original.
			// Ou seja, limpe a tag de leitura final.
			enquanto (início != -1)
			{
				se (!Bit_GetBit(leitura, início))
				{
					se (YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_TEXT][0] != -1)
					{
						format(linha, sizeof (linha), "%s = %s" INI_NEW_LINE, YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_NAME], YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_TEXT]);
						fwrite(buffer, linha);
					}
				}
				início = YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_NEXT];
			}
			fclose(source);
		}
		// Escreva quaisquer grupos de tags não encontrados no arquivo original.
		para (novo j = 0; j < tagpos; j++)
		{
			//se (!(tags escritas & Bit:(1 << j)))
			se (!Bit_Get(tagswritten, j))
			{
				início = YSI_g_sINIWriteTag[_:arquivo][j][E_INI_TAGS_START];
				se (j || YSI_g_sINIWriteTag[_:file][0][E_INI_TAGS_NAME][0])
				{
					strunpack(linha, YSI_g_sINIWriteTag[_:arquivo][j][E_INI_TAGS_NAME]);
					format(linha, sizeof(linha), "[%s]" INI_NEW_LINE, linha);
					fwrite(buffer, linha);
				}
				enquanto (início != -1)
				{
					se (YSI_g_sINIWriteBuffer[_:file][start][E_INI_WRITE_TEXT][0] != -1)
					{
						format(linha, sizeof (linha), "%s = %s" INI_NEW_LINE, YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_NAME], YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_TEXT]);
						fwrite(buffer, linha);
					}
					início = YSI_g_sINIWriteBuffer[_:arquivo][início][E_INI_WRITE_NEXT];
				}
			}
		}
		//fclose(buffer);
		// Isso renomeia o arquivo de volta (copiando todos os dados).
		fremove(YSI_g_sINIWriteFile[_:arquivo]);
		#se definido _inc_TODO_COPY_INC
		#outro
			#se definido _int_TODO_OTHER_COPY_INC
			#outro
				fonte = fopen(YSI_g_sINIWriteFile[_:arquivo], io_write);
				//buffer = fopen("_temp_ysi_user_file_.ysi", io_read);
				fseek(buffer);
				se (fonte) // && buffer)
				{
					enquanto (ler(buffer, linha)) escrever(fonte, linha);
					/*novo
						vale;
					printf("início: %d", _:E_INI_WRITE * INI_BUFFER_SIZE);
					enquanto ((val = fblockread(buffer, YSI_g_sINIWriteBuffer[_:file][0][E_INI_WRITE_NAME], _:E_INI_WRITE * INI_BUFFER_SIZE)))
					{
						printf("%d %d", val, strlen(YSI_g_sINIWriteBuffer[_:file][0][E_INI_WRITE_NAME]));
						printf("%s", YSI_g_sINIWriteBuffer[_:file][0][E_INI_WRITE_NAME]);
						fblockwrite(source, YSI_g_sINIWriteBuffer[_:file][0][E_INI_WRITE_NAME], val);
					}*/
					fclose(buffer);
					fclose(source);
				}
				//fremove("_temp_ysi_user_file_.ysi");
			#fim
		#fim
		// Reinicializa o buffer de escrita.
		YSI_g_sINITagPos[_:file] = 0;
		YSI_g_sINIWritePos[_:arquivo] = 0;
		YSI_g_sINICurrentTag[_:arquivo] = 0;
		retornar 1;
	}
	retornar 0;
}
