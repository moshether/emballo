{   Copyright 2009, 2010 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Emballo.
    If not, see <http://www.gnu.org/licenses/>. }

unit EBDIRegistry;

interface

uses
  EBFieldEnumerator, Classes, EBFactory, EBInjectable;

type
  IDIRegistry = interface
    ['{98BB0741-2586-4039-98C1-11CD97D4B25F}']
    procedure RegisterFactory(const Factory: IFactory); overload;
    procedure RegisterFactory(Guid: TGUID; ClassType: TClass;
      ConstructorAddress: Pointer); overload;
    procedure RegisterFactory(Guid: TGUID; Injectable: TInjectableClass); overload;
    procedure RegisterFactory(Guid: TGUID; Instance: IInterface); overload;
    function Instantiate(GUID: TGUID): IInterface;
    procedure RegisterFactorySingleton(Guid: TGUID; ClassType: TClass;
      ConstructorAddress: Pointer); overload;
    procedure RegisterFactorySingleton(Guid: TGUID; Injecable: TInjectableClass); overload;

    procedure Clear;
  end;

  TDIRegistryImpl = class(TInterfacedObject, IDIRegistry)
  private
    FFactories: IInterfaceList;
    procedure RegisterFactory(const Factory: IFactory); overload;
    procedure RegisterFactory(Guid: TGUID; ClassType: TClass;
      ConstructorAddress: Pointer); overload;
    procedure RegisterFactory(Guid: TGUID; Injectable: TInjectableClass); overload;
    procedure RegisterFactory(Guid: TGUID; Instance: IInterface); overload;
    function Instantiate(GUID: TGUID): IInterface;
    procedure RegisterFactorySingleton(Guid: TGUID; ClassType: TClass;
      ConstructorAddress: Pointer); overload;
    procedure RegisterFactorySingleton(Guid: TGUID; Injecable: TInjectableClass); overload;
    procedure Clear;
  public
    constructor Create;
  end;

function GetDIRegistry: IDIRegistry;

implementation

uses
  SysUtils, EBDynamicFactory, EBInjectableFactory, EBPreBuiltFactory,
  EBSingletonFactory;

var
  _DIRegistry: IDIRegistry;

function GetDIRegistry: IDIRegistry;
begin
  Result := _DIRegistry;
end;

{ TDIRegistryImpl }

procedure TDIRegistryImpl.Clear;
begin
  FFactories.Clear;
end;

constructor TDIRegistryImpl.Create;
begin
  FFactories := TInterfaceList.Create;
end;

function TDIRegistryImpl.Instantiate(GUID: TGUID): IInterface;
var
  i: Integer;
  Factory: IFactory;
begin
  Result := Nil;
  for i := 0 to FFactories.Count - 1 do
  begin
    Factory := FFactories[i] as IFactory;
    if IsEqualGUID(Factory.GUID, GUID) then
    begin
      Result := Factory.GetInstance;
      Break;
    end;
  end;
end;

procedure TDIRegistryImpl.RegisterFactory(Guid: TGUID; Injectable: TInjectableClass);
begin
  RegisterFactory(TInjectableFactory.Create(Guid, Injectable));
end;

procedure TDIRegistryImpl.RegisterFactory(Guid: TGUID; ClassType: TClass;
  ConstructorAddress: Pointer);
begin
  RegisterFactory(TDynamicFactory.Create(Guid, ClassType, ConstructorAddress));
end;

procedure TDIRegistryImpl.RegisterFactory(const Factory: IFactory);
begin
  FFactories.Add(Factory);
end;

procedure TDIRegistryImpl.RegisterFactory(Guid: TGUID; Instance: IInterface);
begin
  RegisterFactory(TPreBuiltFactory.Create(Guid, Instance));
end;

procedure TDIRegistryImpl.RegisterFactorySingleton(Guid: TGUID;
  ClassType: TClass; ConstructorAddress: Pointer);
begin
  RegisterFactory(TSingletonFactory.Create(TDynamicFactory.Create(Guid, ClassType, ConstructorAddress)));
end;

procedure TDIRegistryImpl.RegisterFactorySingleton(Guid: TGUID;
  Injecable: TInjectableClass);
begin
  RegisterFactory(TSingletonFactory.Create(TInjectableFactory.Create(Guid, Injecable)));
end;

initialization
_DIRegistry := TDIRegistryImpl.Create;

end.
