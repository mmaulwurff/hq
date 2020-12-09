version "4.5.0"

/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020
 *
 * This file is part of Headquarters.
 *
 * Headquarters is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Headquarters is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Headquarters.  If not, see <https://www.gnu.org/licenses/>.
 */

class hq_EventHandler : EventHandler
{

  override void worldLoaded(WorldEvent event)
  {
    if (level.mapname ~== HQ_MAP_NAME)
    {
      level.nextmap = Cvar.GetCvar(BACKMAP_CVAR).getString();
    }
    else
    {
      string positionString = Cvar.getCvar(POSITION_CVAR).getString();
      if (positionString.length() != 0)
      {
        Dictionary positionDict = Dictionary.fromString(positionString);
        double x = positionDict.at("x").toDouble();
        double y = positionDict.at("y").toDouble();
        double z = positionDict.at("z").toDouble();
        double angle = positionDict.at("angle").toDouble();

        Actor player = players[consolePlayer].mo;
        player.Teleport((x, y, z), angle, TF_USESPOTZ);

        Cvar.getCvar(POSITION_CVAR).setString("");
      }

      CVar.GetCvar(BACKMAP_CVAR).setString(level.mapname);
    }
  }

  override void networkProcess(ConsoleEvent event)
  {
    if (event.name == "go_to_hq")
    {
      if (level.mapname ~== HQ_MAP_NAME) return;

      Actor player = players[consolePlayer].mo;
      Dictionary positionDict = Dictionary.Create();
      positionDict.insert("x", string.Format("%f", player.pos.x));
      positionDict.insert("y", string.Format("%f", player.pos.y));
      positionDict.insert("z", string.Format("%f", player.pos.z));
      positionDict.insert("angle", string.Format("%f", player.angle));
      Cvar.getCvar(POSITION_CVAR).setString(positionDict.toString());

      level.changeLevel(HQ_MAP_NAME, 0, CHANGELEVEL_NOINTERMISSION);
    }

    if (event.name == "go_back_from_hq" && level.mapname ~== HQ_MAP_NAME)
    {
      level.changeLevel(CVar.GetCvar(BACKMAP_CVAR).getString(), 0, CHANGELEVEL_NOINTERMISSION);
    }
  }

  const HQ_MAP_NAME = "test";
  const BACKMAP_CVAR = "hq_backmap";
  const POSITION_CVAR = "hq_position";

} // class hq_EventHandler
