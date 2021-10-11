{-------------------------------------------------------}
{                                                       }
{    casse tête sur plateau où l'on doit amener les     }
{    chevaux blancs sur les cases des chevaux noirs     }
{                     et inversement                    }
{    les déplacements des chevaux autorisés sont les    }
{    mêmes que ceux des cavaliers au jeu des échecs     }
{                                                       }
{    auteur: zwyx                                       }
{    date: 2008                                         }
{                                                       }
{-------------------------------------------------------}

unit UnitJeu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, UnitHistorique;

type
  TFormJeu = class(TForm)
    pnlJeu: TPanel;
    imgPlateau: TImage;
    imgPion1: TImage;
    imgPion2: TImage;
    imgPion4: TImage;
    imgPion3: TImage;
    btnAnnuler: TButton;
    btnInitialiser: TButton;
    btnResoudre: TButton;
    btnAide: TButton;
    mmoTexte: TMemo;
    procedure ShowForm(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Initialiser();
    procedure Reinitialiser(Sender: TObject);
    procedure Placer1Pion(Pion: TImage; PosX, PosY: Char);
    procedure Placer4Pions(Placement: TPlacementPions);
    procedure Ecrire(Msg: ShortString);
    procedure IntercepterClavier(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DeplacerPion(Sender, Source: TObject; X, Y: Integer);
    procedure AutoriserDeplacementPion(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure AnnulerDeplacement(Sender: TObject);
    function CalculerPlacement(): TPlacementPions;
    function TesterSiGagne(Placement: TPlacementPions): Boolean;
    procedure CacherJeu();
    procedure AfficherAide(Sender: TObject);
    procedure Resoudre(Sender: TObject);
  private
  public
  end; // class

const
  BOX: Word = 100; // taille d'une case ou d'un pion, en pixels
  TITRE: ShortString = 'Cavalry '; // titre de FormJeu, la fenêtre du programme

var
  FormJeu: TFormJeu; // fenêtre de l'application
  PlacementInitial: TPlacementPions; // placement initial des pions
  PlacementFinal: array [1..4] of TPlacementPions; // placements des pions auxquels il faut parvenir pour résoudre le puzzle, comme les pions de même couleur peuvent être intervertis, il y a 4 solutions
  NbDeplacements: Word; // nombre de déplacements effectués, incrémenté même quand on annule le dernier déplacement
  Histoire: THistorique; // pile des placements précédents des pions

{-------------------------------------------------------}
{                     implémentation                    }
{-------------------------------------------------------}

implementation
{$R *.dfm}

{-------------------------------------------------------}
// procédure appelée à l'affichage de la fenêtre, charge les images dans les composants TImage
procedure TFormJeu.ShowForm(Sender: TObject);
begin
  imgPlateau.Picture.LoadFromFile('plateau.bmp');
  imgPion1.Picture.LoadFromFile('chevalblanc.bmp');
  imgPion2.Picture.LoadFromFile('chevalblanc.bmp');
  imgPion3.Picture.LoadFromFile('chevalnoir.bmp');
  imgPion4.Picture.LoadFromFile('chevalnoir.bmp');
  Initialiser;
end; // procedure

{-------------------------------------------------------}
// procédure appelée à la fermeture de la fenêtre du programme, détruit l'historique des déplacements
procedure TFormJeu.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Histoire.Free;
end; // procedure

{-------------------------------------------------------}
// initialise le jeu, dès le début d'une partie
procedure TFormJeu.Initialiser();
begin
  PlacementInitial := 'A1A3D2B3';
  PlacementFinal[1] := 'D2B3A1A3';
  PlacementFinal[2] := 'D2B3A3A1';
  PlacementFinal[3] := 'B3D2A1A3';
  PlacementFinal[4] := 'B3D2A3A1';
  Ecrire('Debut'#9#9#9#9'['+PlacementInitial+']');
  Placer4Pions(PlacementInitial);
  Histoire := THistorique.Create;
  Histoire.Empiler(PlacementInitial);
  NbDeplacements := 0;
end; // procedure

{-------------------------------------------------------}
// vide l'historique et replace les pions suivant la position intiale
procedure TFormJeu.Reinitialiser(Sender: TObject);
begin
  mmoTexte.Clear;
  Caption := TITRE;
  Ecrire('Debut'#9#9#9#9'['+PlacementInitial+']');
  Placer4Pions(PlacementInitial);
  Histoire.Free;
  Histoire := THistorique.Create;
  Histoire.Empiler(PlacementInitial);
  NbDeplacements := 0;
end; // procedure

{-------------------------------------------------------}
// place l'image Pion à la ligne '1', '2', '3' ou '4', de la colonne 'A', 'B', 'C' ou 'D'
procedure TFormJeu.Placer1Pion(Pion: TImage; PosX, PosY: Char);
begin
  TImage(Pion).Left := (Byte(PosX)-65)*BOX; // 'A', code ascii #65
  TImage(Pion).Top := (Byte(PosY)-49)*BOX; // '1', code ascii #49
end; // procedure

{-------------------------------------------------------}
// place les quatres pions du jeu au positions respectives Placement[1..2], Placement[3..4], Placement[5..6] et Placement[7..8]
procedure TFormJeu.Placer4Pions(Placement: TPlacementPions);
begin
  Placer1Pion(imgPion1, Placement[1], Placement[2]);
  Placer1Pion(imgPion2, Placement[3], Placement[4]);
  Placer1Pion(imgPion3, Placement[5], Placement[6]);
  Placer1Pion(imgPion4, Placement[7], Placement[8]);
end; // procedure

{-------------------------------------------------------}
// affiche une nouvelle ligne dans mmoTexte, les anciennes lignes se retrouvent en bas
procedure TFormJeu.Ecrire(Msg: ShortString);
begin
  mmoTexte.Text := Msg+#13#10+mmoTexte.Text;
end; // procedure

{-------------------------------------------------------}
// réagit à certaines touches pressées par l'utilisateur
// ctrl: cache la fenêtre ou la fait réapparaitre
// del: annule le dernier mouvement
// échap: quitte le programme
// entrée: résout le puzzle
// F1: affiche l'aide
// F2: réinitialise la partie
procedure TFormJeu.IntercepterClavier(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case key of
    VK_CONTROL: CacherJeu; // ctrl
    VK_BACK: AnnulerDeplacement(Sender); // del
    VK_ESCAPE: Close; // échap
    VK_RETURN: Resoudre(Sender); // entrée
    VK_F1: AfficherAide(Sender); // F1
    VK_F2: Reinitialiser(Sender); // F2
  end; // case
end; // procedure

{-------------------------------------------------------}
// gère le glisser-déplacer d'une image d'un pion, sur TPanel pnlJeu
procedure TFormJeu.DeplacerPion(Sender, Source: TObject; X,
  Y: Integer);
var
  Placement: TPlacementPions;
  Msg: ShortString;
begin
  // rédaction de la première partie du message décrivant le déplacement effectué
  Placement := CalculerPlacement;
  if Source=imgPion1 then
    Msg := 'cheval blanc 1: '+Placement[1]+Placement[2]+' -> '
  else if Source=imgPion2 then
    Msg := 'cheval blanc 2: '+Placement[3]+Placement[4]+' -> '
  else if Source=imgPion3 then
    Msg := 'cheval noir 1: '+Placement[5]+Placement[6]+' -> '
  else // if Source=imgPion4 then
    Msg := 'cheval noir 2: '+Placement[7]+Placement[8]+' -> ';
  // déplacement de l'image du pion correspondant
  TImage(Source).Left := (X div BOX) * BOX;
  TImage(Source).Top := (Y div BOX) * BOX;
  Placement := CalculerPlacement;
  // rédaction de la seconde partie du message décrivant le déplacement effectué
  if Source=imgPion1 then
    Msg := Msg+Placement[1]+Placement[2]
  else if Source=imgPion2 then
    Msg := Msg+Placement[3]+Placement[4]
  else if Source=imgPion3 then
    Msg := Msg+Placement[5]+Placement[6]
  else // if Source=imgPion4 then
    Msg := Msg+Placement[7]+Placement[8];
  // écriture du message dans mmoTexte et du nombre de coups joués en Caption de la fenêtre
  Ecrire(Msg+#9#9'['+Placement+']');
  Inc(NbDeplacements);
  if NbDeplacements>1 then
    Caption := TITRE+#32#126#32+IntToStr(NbDeplacements)+' replacements'
  else
    Caption := TITRE+#32#126#32+IntToStr(NbDeplacements)+' replacement';
  // ajout du placement à la pile et test si le puzzle est résolu
  Histoire.Empiler(Placement);
  if TesterSiGagne(Placement) then
    ShowMessage('Félicitations, vous avez gagné en '+IntToStr(NbDeplacements)+' coups.');
end; // procedure

{-------------------------------------------------------}
// pour accepter le déplacement d'un pion sur pnlJeu, si le mouvement est conforme à celui d'un cavalier
procedure TFormJeu.AutoriserDeplacementPion(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  PosXi, PosYi, PosXf, PosYf: Byte; // positions initiales et finales du pion déplacé
begin
  // avant toute vérification, s'il s'agit d'un pion, on accepte le déplacement
  if (Source=imgPion1) or (Source=imgPion2) or (Source=imgPion3) or (Source=imgPion4) then
    Accept := True;
  // calcul des positions initiales et finales du pion déplacé, en numéros de ligne et de colonne
  PosXi := TImage(Source).Left div BOX +1;
  PosYi := TImage(Source).Top div BOX +1;
  PosXf := X div BOX +1;
  PosYf := Y div BOX +1;
  // vérification qu'on n'essaie pas de déplacer le pion hors du plateau de jeu
  case PosYf of
    1: if PosXf>1 then Accept := False;
    //2: aucune contrainte, la ligne 2 contient 4 colonnes
    3: if PosXf>3 then Accept := False;
    4: if PosXf>2 then Accept := False;
  end; // case
  // vérifivation que la trajectoire est bien celle d'un cavalier aux échecs
  if Abs(PosXf-PosXi)>2 then
    Accept := False;
  if Abs(PosXf-PosXi)=1 then
    if Abs(PosYf-PosYi)<>2 then
      Accept := False;
  if Abs(PosXf-PosXi)=2 then
    if Abs(PosYf-PosYi)<>1 then
      Accept := False;
  if Abs(PosYf-PosYi)>2 then
    Accept := False;
  if Abs(PosYf-PosYi)=1 then
    if Abs(PosXf-PosXi)<>2 then
      Accept := False;
  if Abs(PosYf-PosYi)=2 then
    if Abs(PosXf-PosXi)<>1 then
      Accept := False;
end; // procedure

{-------------------------------------------------------}
// annule le dernier déplacement en le dépilant de l'historique et en replacant les quatres pions
procedure TFormJeu.AnnulerDeplacement(Sender: TObject);
var
  Placement: TPlacementPions;
begin
  if Histoire.RecupererNbPlacements>1 then
  begin
    Placement := Histoire.Depiler;
    Placer4Pions(Placement);
    Inc(NbDeplacements);
    Caption := TITRE+#32#126#32+IntToStr(NbDeplacements)+' replacements.';
    Ecrire('dernier déplacement annulé'#9#9'['+Placement+']');
  end; // if
end; // procedure

{-------------------------------------------------------}
// convertit les positions des quatre pions en une chaîne de type TPlacementPions
function TFormJeu.CalculerPlacement(): TPlacementPions;
var
  PosX, PosY: Byte; // ligne et colonne de chacun des quatre pions
begin
  Result := '        ';
  // première image, pour le cheval blanc 1
  PosX := imgPion1.Left div BOX +1;
  PosY := imgPion1.Top div BOX +1;
  Result[1] := Char(PosX+64); // 'A', code ascii #65
  Result[2] := Char(PosY+48); // '1', code ascii #49
  // deuxième image, pour le cheval blanc 2
  PosX := imgPion2.Left div BOX +1;
  PosY := imgPion2.Top div BOX +1;
  Result[3] := Char(PosX+64); // 'A', code ascii #65
  Result[4] := Char(PosY+48); // '1', code ascii #49
  // troisième image, pour le cheval noir 1
  PosX := imgPion3.Left div BOX +1;
  PosY := imgPion3.Top div BOX +1;
  Result[5] := Char(PosX+64); // 'A', code ascii #65
  Result[6] := Char(PosY+48); // '1', code ascii #49
  // quatrième image, pour le cheval noir 2
  PosX := imgPion4.Left div BOX +1;
  PosY := imgPion4.Top div BOX +1;
  Result[7] := Char(PosX+64); // 'A', code ascii #65
  Result[8] := Char(PosY+48); // '1', code ascii #49 
end; // function

{-------------------------------------------------------}
// teste si le placement des pions correspond à un des quatre gagnant
function TFormJeu.TesterSiGagne(Placement: TPlacementPions): Boolean;
var
  i: Byte; // compteur de boucle
begin
  Result := False;
  // teste si on a le premier placement gagnant
  for i := 1 to 8 do // 8 caractères par placement de pions
  begin
    if Placement[i]<>PlacementFinal[1][i] then
      Break // sort de la boucle for
    else if i=8 then
    begin
      Result := True;
      Exit;
    end; // else if
  end; // for
  // teste si on a le deuxième placement gagnant
  for i := 1 to 8 do // 8 caractères par placement de pions
  begin
    if Placement[i]<>PlacementFinal[2][i] then
      Break // sort de la boucle for
    else if i=8 then
    begin
      Result := True;
      Exit;
    end; // else if
  end; // for
  // teste si on a le troisième placement gagnant
  for i := 1 to 8 do // 8 caractères par placement de pions
  begin
    if Placement[i]<>PlacementFinal[3][i] then
      Break // sort de la boucle for
    else if i=8 then
    begin
      Result := True;
      Exit;
    end; // else if
  end; // for
  // teste si on a le quatrième placement gagnant
  for i := 1 to 8 do // 8 caractères par placement de pions
  begin
    if Placement[i]<>PlacementFinal[4][i] then
      Break // sort de la boucle for
    else if i=8 then
    begin
      Result := True;
      Exit;
    end; // else if
  end; // for

end; // function

{-------------------------------------------------------}
// cache le jeu en rendant la fenêtre transparente
// si le jeu était déjà caché, il redevient visible
procedure TFormJeu.CacherJeu();
begin
  if AlphaBlend=False then // on cache le jeu
    AlphaBlend := True
  else // on rend le jeu visible
    AlphaBlend := False;
end; // procedure

{-------------------------------------------------------}
// affiche le message d'aide
procedure TFormJeu.AfficherAide(Sender: TObject);
var
  Msg: AnsiString;
  NewLine: ShortString;
  Tab: Char;
begin
  NewLine := #13#10;
  Tab := #9;
  Msg := Tab+'OBJECTIF'+NewLine+Tab+'________'+NewLine+NewLine;
  Msg := Msg+'Pour résoudre ce puzzle, vous devez placer les chevaux blancs sur les cases des chevaux noirs, et inversement.'+NewLine+NewLine;
  Msg := Msg+'Les mouvements autorisés pour les cavaliers sont les mêmes que dans le jeu des échecs.'+NewLine+NewLine;
  Msg := Msg+Tab+'COMMANDES'+NewLine+Tab+'___________'+NewLine+NewLine;
  Msg := Msg+'souris: déplacer les pions (glisser-déplacer)'+NewLine;
  Msg := Msg+'F1: afficher l''aide'+NewLine;
  Msg := Msg+'F2: réinitialiser la partie'+NewLine;
  Msg := Msg+'del: annuler le dernier coup'+NewLine;
  Msg := Msg+'ctrl: cacher le jeu'+NewLine;
  Msg := Msg+'echap: quitter le programme'+NewLine;
  Msg := Msg+'entrée: résoudre le puzzle'+NewLine+NewLine;
  Msg := Msg+Tab+'AUTEUR'+NewLine+Tab+'_______'+NewLine+NewLine;
  Msg := Msg+'date: 2008'+NewLine;
  Msg := Msg+'auteur: zwyx'+NewLine;
  ShowMessage(Msg);
  Finalize(Msg);
end; // procedure

{-------------------------------------------------------}
// réaslise consécutivement tous les déplacements qui permettent de résouder le puzzle
procedure TFormJeu.Resoudre(Sender: TObject);
var
  Placements: array[0..40] of TPlacementPions; // les 40 étapes plus celle du départ, pour résoudre le puzzle
  i: Byte; // compteur de boucle
begin
  Placements[0] := 'A1A3D2B3';
  Placements[1] := 'C2A3D2B3';
  Placements[2] := 'B4A3D2B3';
  Placements[3] := 'A2A3D2B3';
  Placements[4] := 'C3A3D2B3';
  Placements[5] := 'C3A3D2A1';
  Placements[6] := 'C3A3D2C2';
  Placements[7] := 'C3A3D2B4';
  Placements[8] := 'C3A3D2A2';
  Placements[9] := 'C3A3B3A2';
  Placements[10] := 'C3A3A1A2';
  Placements[11] := 'C3A3C2A2';
  Placements[12] := 'C3A3B4A2';
  Placements[13] := 'C3C2B4A2';
  Placements[14] := 'C3A1B4A2';
  Placements[15] := 'C3B3B4A2';
  Placements[16] := 'C3D2B4A2';
  Placements[17] := 'C3D2C2A2';
  Placements[18] := 'C3D2A1A2';
  Placements[19] := 'C3D2B3A2';
  Placements[20] := 'C3D2B3B4';
  Placements[21] := 'C3D2B3C2';
  Placements[22] := 'C3D2B3A1';
  Placements[23] := 'A2D2B3A1';
  Placements[24] := 'B4D2B3A1';
  Placements[25] := 'C2D2B3A1';
  Placements[26] := 'A3D2B3A1';
  Placements[27] := 'A3D2B3C2';
  Placements[28] := 'A3D2B3B4';
  Placements[29] := 'A3D2B3A2';
  Placements[30] := 'A3D2A1A2';
  Placements[31] := 'A3D2C2A2';
  Placements[32] := 'A3D2B4A2';
  Placements[33] := 'C2D2B4A2';
  Placements[34] := 'A1D2B4A2';
  Placements[35] := 'B3D2B4A2';
  Placements[36] := 'B3D2C2A2';
  Placements[37] := 'B3D2A1A2';
  Placements[38] := 'B3D2A1B4';
  Placements[39] := 'B3D2A1C2';
  Placements[40] := 'B3D2A1A3';
  for i := 0 to 40 do
  begin
    Placer4Pions(Placements[i]);
    pnlJeu.Repaint;
    Sleep(500);
  end; // for
    Ecrire('Et voilà le travail ! A votre tour maintenant.');
end; // procedure

{-------------------------------------------------------}

end. // unit
