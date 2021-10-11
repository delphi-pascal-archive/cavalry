{-------------------------------------------------------}
{                                                       }
{    casse t�te sur plateau o� l'on doit amener les     }
{    chevaux blancs sur les cases des chevaux noirs     }
{                     et inversement                    }
{    les d�placements des chevaux autoris�s sont les    }
{    m�mes que ceux des cavaliers au jeu des �checs     }
{                                                       }
{    auteur: zwyx                                       }
{    date: 2008                                         }
{                                                       }
{-------------------------------------------------------}

unit UnitHistorique;

{-------------------------------------------------------}
{                         interface                     }
{-------------------------------------------------------}

interface

uses
  Classes;

type
  TPlacementPions = String[8]; // placement du pion blanc 1 = 'A1', placement du pion blanc 2 = ...

  THistorique = class // pile de placements des quatre pions
  private
    FNbPlacements: Word; // nombre de TPlacementPions dans FPlacementsPrec
    FPlacementsPrec: array [Word] of TPlacementPions; // placements des pions pr�c�dents pour m�moriser les d�placements
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Empiler(Placement: TPlacementPions);
    function Depiler(): TPlacementPions;
    function RecupererNbPlacements(): Word;
  end; // class

{-------------------------------------------------------}
{                     impl�mentation                    }
{-------------------------------------------------------}

implementation

{-------------------------------------------------------}
constructor THistorique.Create();
begin
  inherited;
  FNbPlacements := 0;
end; // constructor

{-------------------------------------------------------}
destructor THistorique.Destroy();
var
  i: Word; // compteur de boucles, pour d�truires toutes les cha�nes de FPlacementsPrec
begin
  for i := 0 to FNbPlacements-1 do
    Finalize(FPlacementsPrec[i]);
  inherited;
end; // destructor

{-------------------------------------------------------}
// ajoute une cha�ne � la pile, indiquant un placement des quatre pions
procedure THistorique.Empiler(Placement: TPlacementPions);
begin
  FPlacementsPrec[FNbPlacements] := Placement;
  Inc(FNbPlacements);
end; // procedure

{-------------------------------------------------------}
// retire la premi�re ligne indiquant un placement des quatre pions de la pile
function THistorique.Depiler(): TPlacementPions;
begin
  if FNbPlacements>1 then
  begin
    Result := FPlacementsPrec[FNbPlacements-2]; // r�cup�re l'avant dernier placement
    Finalize(FPlacementsPrec[FNbPlacements-1]); // supprime le dernier placement
    Dec(FNbPlacements);
  end; // if
end; // function

{-------------------------------------------------------}
// accesseur de FNbPlacements
function THistorique.RecupererNbPlacements(): Word;
begin
  Result := FNbPlacements;
end; // function

{-------------------------------------------------------}

end. // unit

